#!/usr/bin/env python3
"""Executable validator for VG App v0.2.8 planning pack."""
from __future__ import annotations
import re, sys
from pathlib import Path
from typing import Any
try:
    import yaml
except Exception as exc:
    print(f"FAIL: PV-000 PyYAML required: {exc}")
    sys.exit(1)

CHECKS=[]
YAML_FENCE_RE=re.compile(r"```(yaml|yml|yaml-example)\n(.*?)\n```", re.S)
REQUIRED_ACTION_KEYS={"action_type","ash_action_kind","visibility","accepted_arguments","returns","errors","primary_resource","mutates_resources"}
FORBIDDEN_ACTIVE_REFS={"Events","Learning","Competitions","Media","Community","Shipping","Tax","FulfilmentDispatch","AuditEvent","GenericCatalog","ProductVariants","Inventory","CartFirstCheckout","FullRefunds","Bundles","CouponStacking","OrganiserPortal","DigitalDownloads","AutomaticRecurringBilling","PaystackSubscriptionLifecycle","DiscountCalculation"}

def record(cid, desc, ok):
    CHECKS.append((cid,desc,ok)); print(("PASS" if ok else "FAIL")+f": {cid} {desc}")

def read(p:Path): return p.read_text(encoding='utf-8')
def load(p:Path): return yaml.safe_load(read(p))

def yaml_blocks(root:Path):
    for p in sorted(root.rglob('*')):
        if p.is_file() and p.suffix in {'.md','.yml','.yaml'}:
            for m in YAML_FENCE_RE.finditer(read(p)):
                yield p, m.group(1), m.group(2)

def yaml_cards(path:Path, key:str):
    cards=[]
    for m in YAML_FENCE_RE.finditer(read(path)):
        if m.group(1) not in {'yaml','yml'}: continue
        data=yaml.safe_load(m.group(2))
        if isinstance(data,dict) and key in data: cards.append(data)
    return cards

def yaml_doc(path:Path, key:str):
    for m in YAML_FENCE_RE.finditer(read(path)):
        if m.group(1) not in {'yaml','yml'}: continue
        data=yaml.safe_load(m.group(2))
        if isinstance(data,dict) and key in data: return data
    return {}

def extract_bullets_after(text, heading):
    idx=text.find(heading)
    if idx < 0: return []
    rest=text[idx+len(heading):]
    nxt=re.search(r"\n## ", rest)
    if nxt: rest=rest[:nxt.start()]
    vals=[]
    for line in rest.splitlines():
        line=line.strip()
        if line.startswith('- '):
            v=line[2:].strip().strip('`')
            if v and v.lower()!='none': vals.append(v)
    return vals

def slice_refs(path):
    t=read(path)
    return extract_bullets_after(t,'## Resources involved'), extract_bullets_after(t,'## Actions involved'), extract_bullets_after(t,'## Blocking decisions'), t

def collect_tests(obj:Any):
    out=set()
    if isinstance(obj,dict):
        for k,v in obj.items():
            if k in {'tests','tests_required','required_tests','global_required_tests'} and isinstance(v,list): out.update(str(x) for x in v)
            else: out.update(collect_tests(v))
    elif isinstance(obj,list):
        for x in obj: out.update(collect_tests(x))
    return out

def main():
    root=Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve()
    pack_path=root/'planning-pack.yml'
    record('PV-001','planning-pack.yml exists',pack_path.exists())
    try:
        pack=load(pack_path); record('PV-001B','planning-pack.yml parses',isinstance(pack,dict))
    except Exception as exc:
        record('PV-001B',f'planning-pack.yml parses ({exc})',False); pack={}
    y_ok=True
    for p,lang,body in yaml_blocks(root):
        try: yaml.safe_load(body)
        except Exception as exc:
            y_ok=False; print(f"FAIL: PV-002 {p.relative_to(root)} {lang}: {exc}")
    record('PV-002','all YAML fences parse',y_ok)
    res_cards=yaml_cards(root/'05-resource-cards.md','resource'); act_cards=yaml_cards(root/'06-action-cards.md','action')
    resources={c['resource']:c for c in res_cards}; actions={c['action']:c for c in act_cards}
    record('PV-003','all planning-pack resources have resource cards',set(pack.get('resources') or []) <= set(resources))
    slice_files=sorted((root/'slice-packs').glob('VS-*.md'))
    existing={p.name.split('-')[0]+'-'+p.name.split('-')[1] for p in slice_files}
    record('PV-004','all planning-pack slices exist',set(pack.get('slices') or []) <= existing)
    sres_ok=sact_ok=forbid_ok=True
    used_refs=[]
    for sf in slice_files:
        sres,sact,blockers,text=slice_refs(sf); used_refs.extend(sres+sact)
        mr=[r for r in sres if r not in resources]
        ma=[a for a in sact if a not in actions]
        if mr: sres_ok=False; print(f"FAIL: PV-005 {sf.name} missing resource cards {mr}")
        if ma: sact_ok=False; print(f"FAIL: PV-006 {sf.name} missing action cards {ma}")
    bad=[r for r in used_refs if r in FORBIDDEN_ACTIVE_REFS]
    if bad: forbid_ok=False; print(f"FAIL: PV-007 forbidden active refs {bad}")
    record('PV-005','all slice resources have cards',sres_ok)
    record('PV-006','all slice actions have cards',sact_ok)
    record('PV-007','no active slice uses forbidden scope refs',forbid_ok)
    active_actions=set()
    for c in res_cards: active_actions.update(str(a) for a in c.get('actions_active_v0_2') or [])
    record('PV-008','all active resource actions have action cards',active_actions <= set(actions))
    matrix_tests=collect_tests(load(root/'14-test-matrix.yml'))
    card_tests=set()
    for c in res_cards+act_cards: card_tests.update(str(t) for t in c.get('tests_required') or [])
    missing=sorted(card_tests-matrix_tests)
    if missing: print(f"FAIL: PV-009 missing tests {missing}")
    record('PV-009','all card tests appear in matrix',not missing)
    all_text='\n'.join(read(p) for p in root.rglob('*') if p.is_file() and p.suffix in {'.md','.yml','.yaml'})
    record('PV-010','no MyApp placeholders',not re.search(r'\bMyApp\.|:my_app|lib/my_app',all_text))
    record('PV-011','Store_Blueprint decision file exists',(root/'references/STORE_BLUEPRINT_EXTRACTION_DECISION_V1.md').exists())
    f_ok=fs_ok=True
    for rn,c in resources.items():
        fs=c.get('field_schema')
        if not isinstance(fs,list) or not fs:
            f_ok=False; print(f"FAIL: PV-012 {rn} missing field_schema")
            continue
        for fld in fs:
            if not isinstance(fld,dict) or not {'name','type','required','nullable'} <= set(fld):
                fs_ok=False; print(f"FAIL: PV-013 {rn} bad field {fld}")
    record('PV-012','all resources have field_schema',f_ok)
    record('PV-013','all fields have name/type/required/nullable',fs_ok)
    contract_ok=True
    for an,c in actions.items():
        missing_keys=REQUIRED_ACTION_KEYS-set(c)
        if missing_keys or not isinstance(c.get('accepted_arguments'),list) or not isinstance(c.get('returns'),dict) or not isinstance(c.get('errors'),list):
            contract_ok=False; print(f"FAIL: PV-014 {an} incomplete contract {sorted(missing_keys)}")
    record('PV-014','all actions have contract shape',contract_ok)
    perms_doc=yaml_doc(root/'12-actor-permission-matrix.md','action_permissions')
    perms=perms_doc.get('action_permissions',{}) if isinstance(perms_doc,dict) else {}
    actor_ok=True
    for an,c in actions.items():
        allowed=perms.get(an,{}).get('allowed_actors') if isinstance(perms.get(an),dict) else None
        if not allowed or c.get('actor') not in allowed:
            actor_ok=False; print(f"FAIL: PV-015 {an} actor {c.get('actor')} not allowed {allowed}")
    record('PV-015','action actors match permission matrix',actor_ok)
    record('PV-016','User has AshAuthentication password/confirmation fields', 'hashed_password' in str(resources.get('User',{})) and 'confirmed_at' in str(resources.get('User',{})) and 'AshAuthentication' in all_text)
    record('PV-017','ConsentRecord exists and marketing consent is separate','ConsentRecord' in resources and 'marketing consent SHALL NOT be bundled' in all_text)
    record('PV-018','AccountRole exists and system is not stored as role','AccountRole' in resources and 'system SHALL NOT be stored as a normal user role' in all_text)
    record('PV-019','MembershipProduct exists and is not generic catalog','MembershipProduct' in resources and 'not a generic product catalog' in str(resources.get('MembershipProduct',{})))
    mp=str(resources.get('MembershipPlan',{}))
    record('PV-020','MembershipPlan supports fixed period and lifetime terms',all(x in mp for x in ['fixed_period','lifetime','duration_interval','duration_interval_count']))
    mem=str(resources.get('Membership',{}))
    record('PV-021','Membership snapshots duration and expiry',all(x in mem for x in ['duration_type_snapshot','duration_interval_snapshot','duration_interval_count_snapshot','expires_at']))
    grant=str(resources.get('EntitlementGrant',{}))
    record('PV-022','EntitlementGrant has validity dates',all(x in grant for x in ['valid_from_at','valid_until_at']))
    pay_event=str(resources.get('PaymentEvent',{}))
    record('PV-023','PaymentEvent owns Paystack idempotency and signature',all(x in pay_event for x in ['provider_event_identity','raw_payload_hash','signature_valid']))
    record('PV-024','Paystack callback presence never delivers value','Callback presence SHALL NOT deliver value' in all_text or 'callback presence SHALL NOT deliver value' in all_text)
    price=str(resources.get('Price',{}))
    record('PV-025','recurring_ready metadata does not implement recurring billing','recurring_ready' in price and 'recurring_ready SHALL NOT mean automatic recurring billing is implemented in v0.2.8' in price)
    vs2c=read(root/'slice-packs/VS-002C-paystack-payment-confirmation.md')
    record('PV-026','VS-002C uses one idempotent fulfilment pipeline',all(x in vs2c for x in ['Callback Verify success MAY provisionally fulfil','Webhook `charge.success` SHALL remain authoritative','Commerce.fulfil_paid_order']))
    vs2d=read(root/'slice-packs/VS-002D-activate-membership-and-grants.md')
    a1=str(actions.get('Memberships.activate_membership',{})); a2=str(actions.get('Memberships.create_entitlement_grants',{}))
    record('PV-027','VS-002D activation and grants are atomic','commit or roll back together' in vs2d and 'commit or roll back together' in a1 and 'commit or roll back together' in a2)
    evala=str(actions.get('Memberships.evaluate_entitlement_access',{}))
    record('PV-028','Access evaluation checks state and dates',all(x in evala for x in ['checks_membership_state_and_dates','checks_grant_state_and_dates']) and 'read-only' in evala)
    record('PV-029','One active membership per user per product invariant exists','A user SHALL NOT have more than one active membership per membership_product_id' in mem)
    record('PV-030','Discount calculation is deferred','Discount calculation SHALL remain deferred' in all_text or 'no discount calculation' in all_text.lower())

    record('PV-031','UUIDv7 primary key law exists','All primary IDs SHALL use UUIDv7' in all_text and 'UUIDv7 ordering SHALL NOT be authoritative business event ordering' in all_text)
    record('PV-032','UTC microsecond timestamp law exists','UTC microsecond precision' in all_text)
    record('PV-033','PaymentMethod exists as active resource','PaymentMethod' in resources and 'Commerce.record_payment_method' in str(resources.get('PaymentMethod',{})))
    record('PV-034','Subscription exists only as deferred resource card','Subscription' in resources and 'active_in_v0_2_7' in str(resources.get('Subscription',{})) and 'false' in str(resources.get('Subscription',{})).lower())
    plan=str(resources.get('MembershipPlan',{}))
    record('PV-035','auto_renewing is modelled but gated',all(x in plan for x in ['renewal_mode','auto_renewing','requires_recurring_capability','SHALL NOT be live/sellable']))
    payment=str(resources.get('Payment',{}))
    record('PV-036','Payment has fulfilment authority and review state',all(x in payment for x in ['fulfilment_authority_state','provisional_verify_success','webhook_confirmed','payment_review']))
    record('PV-037','PaymentEvent stores restricted raw payload and event source',all(x in pay_event for x in ['event_source','raw_payload_encrypted','raw_payload_hash','paystack_verify_api','paystack_webhook']))
    record('PV-038','Callback Verify and webhook use same fulfilment action','Commerce.fulfil_paid_order' in actions and 'same idempotent fulfilment' in str(actions.get('Commerce.fulfil_paid_order',{})))
    record('PV-039','payment_review blocks membership and grant access','payment_review membership SHALL deny access' in mem and 'payment_review grants SHALL deny access' in grant)
    record('PV-040','PaymentMethod does not store raw card data','raw card data SHALL never be stored' in str(resources.get('PaymentMethod',{})))


    # v0.2.8 VS-000 coding-ready checks
    readiness=pack.get('readiness') or {}
    only_vs000 = readiness.get('VS-000') == 'READY_FOR_CODING' and all(v != 'READY_FOR_CODING' for k,v in readiness.items() if k != 'VS-000')
    record('PV-041','only VS-000 is marked READY_FOR_CODING', only_vs000)
    vs000=read(root/'slice-packs/VS-000-backend-membership-commerce-tracer.md')
    record('PV-042','VS-000 automated tests require fake Paystack adapter fixtures','fake Paystack adapter fixtures' in vs000 and 'Automated tests SHALL use fake Paystack adapter fixtures' in vs000)
    record('PV-043','VS-000 manual Paystack sandbox is optional and not CI-required','Manual sandbox smoke tests MAY use Paystack test keys' in vs000 and 'Automated CI SHALL NOT require live Paystack connectivity' in vs000)
    record('PV-044','VS-000 uses one monthly fixed-term plan and calculates expiry','one monthly fixed-term plan' in vs000 and 'calculate `expires_at`' in vs000)
    record('PV-045','VS-000 explicitly forbids UI, subscriptions, recurring billing, and discounts', all(x in vs000 for x in ['Public LiveView pages','Paystack subscription creation','Real recurring billing','Discount calculation']))

    failed=[c for c in CHECKS if not c[2]]
    return 1 if failed else 0
if __name__=='__main__': sys.exit(main())
