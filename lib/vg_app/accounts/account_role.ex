defmodule VgApp.Accounts.AccountRole do
  use Ash.Resource,
    otp_app: :vg_app,
    domain: VgApp.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "account_roles"
    repo VgApp.Repo

    identity_index_names unique_role_per_user: "account_roles_user_role_idx"
  end

  actions do
    defaults [:read]

    create :bootstrap_staff_admin do
      accept [:user_id, :role]
      change {VgApp.Accounts.Changes.SetGrantedAtNow, []}
    end

    create :assign_role do
      accept [:user_id, :role, :granted_by_user_id]
      change {VgApp.Accounts.Changes.SetGrantedAtNow, []}
    end
  end

  policies do
    policy action(:bootstrap_staff_admin) do
      authorize_if {VgApp.Accounts.Checks.SystemActor, []}
    end

    policy action(:assign_role) do
      authorize_if {VgApp.Accounts.Checks.StaffAdmin, []}
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :user_id, :uuid_v7 do
      allow_nil? false
    end

    attribute :role, :atom do
      allow_nil? false
      constraints one_of: [:customer, :staff_admin]
    end

    attribute :state, :atom do
      allow_nil? false
      default :active
      constraints one_of: [:active, :revoked]
    end

    attribute :granted_by_user_id, :uuid_v7

    attribute :granted_at, :utc_datetime_usec do
      allow_nil? false
    end

    attribute :revoked_at, :utc_datetime_usec

    create_timestamp :inserted_at, type: :utc_datetime_usec
    update_timestamp :updated_at, type: :utc_datetime_usec
  end

  relationships do
    belongs_to :user, VgApp.Accounts.User do
      allow_nil? false
      attribute_writable? true
      source_attribute :user_id
      destination_attribute :id
    end

    belongs_to :granted_by_user, VgApp.Accounts.User do
      allow_nil? true
      attribute_writable? true
      source_attribute :granted_by_user_id
      destination_attribute :id
    end
  end

  identities do
    identity :unique_role_per_user, [:user_id, :role]
  end
end
