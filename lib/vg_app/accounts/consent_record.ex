defmodule VgApp.Accounts.ConsentRecord do
  use Ash.Resource,
    otp_app: :vg_app,
    domain: VgApp.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "consent_records"
    repo VgApp.Repo

    identity_index_names unique_active_consent_type_version_per_user:
                           "consent_records_uact_per_user_idx"
  end

  actions do
    defaults [:read]

    create :create do
      accept [
        :user_id,
        :consent_type,
        :consent_version,
        :state,
        :accepted_at,
        :revoked_at,
        :source,
        :ip_address_hash,
        :user_agent_hash
      ]
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if {VgApp.Accounts.Checks.SystemActor, []}
      authorize_if {VgApp.Accounts.Checks.StaffAdmin, []}
      authorize_if expr(user_id == ^actor(:id))
    end

    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :user_id, :uuid_v7 do
      allow_nil? false
    end

    attribute :consent_type, :atom do
      allow_nil? false
      constraints one_of: [:terms, :privacy_policy, :marketing]
    end

    attribute :consent_version, :string do
      allow_nil? false
    end

    attribute :state, :atom do
      allow_nil? false
      default :accepted
      constraints one_of: [:accepted, :revoked]
    end

    attribute :accepted_at, :utc_datetime_usec do
      allow_nil? false
    end

    attribute :revoked_at, :utc_datetime_usec

    attribute :source, :atom do
      allow_nil? false
      constraints one_of: [:registration_form, :account_settings, :admin_import]
    end

    attribute :ip_address_hash, :string
    attribute :user_agent_hash, :string

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
  end

  identities do
    identity :unique_active_consent_type_version_per_user, [
      :user_id,
      :consent_type,
      :consent_version
    ]
  end
end
