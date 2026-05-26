defmodule VgApp.Accounts.UserProfile do
  use Ash.Resource,
    otp_app: :vg_app,
    domain: VgApp.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "user_profiles"
    repo VgApp.Repo
  end

  actions do
    defaults [:read]

    create :create do
      accept [:user_id, :first_name, :last_name, :phone_number]
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

    attribute :first_name, :string do
      allow_nil? false
    end

    attribute :last_name, :string do
      allow_nil? false
    end

    attribute :phone_number, :string

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
    identity :unique_user_profile_per_user, [:user_id]
  end
end
