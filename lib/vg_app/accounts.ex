defmodule VgApp.Accounts do
  use Ash.Domain,
    otp_app: :vg_app

  resources do
    resource VgApp.Accounts.Token
    resource VgApp.Accounts.User
    resource VgApp.Accounts.UserProfile
    resource VgApp.Accounts.ConsentRecord
    resource VgApp.Accounts.AccountRole
  end

  def register_user(attrs) when is_map(attrs) do
    email = Map.get(attrs, :email)
    password = Map.get(attrs, :password)
    password_confirmation = Map.get(attrs, :password_confirmation)

    first_name = Map.get(attrs, :first_name)
    last_name = Map.get(attrs, :last_name)
    phone_number = Map.get(attrs, :phone_number)

    terms_version = Map.get(attrs, :terms_consent_version)
    privacy_version = Map.get(attrs, :privacy_policy_consent_version)
    marketing_consent = Map.get(attrs, :marketing_consent)

    Ash.transaction([VgApp.Accounts.User, VgApp.Accounts.UserProfile, VgApp.Accounts.ConsentRecord], fn ->
      with {:ok, user} <-
             Ash.create(
               VgApp.Accounts.User,
               %{
                 email: email,
                 password: password,
                 password_confirmation: password_confirmation
               },
               action: :register_with_password
             ),
           {:ok, _profile} <-
             Ash.create(
               VgApp.Accounts.UserProfile,
               %{
                 user_id: user.id,
                 first_name: first_name,
                 last_name: last_name,
                 phone_number: phone_number
               },
               action: :create
             ),
           {:ok, _terms} <-
             Ash.create(
               VgApp.Accounts.ConsentRecord,
               %{
                 user_id: user.id,
                 consent_type: :terms,
                 consent_version: terms_version,
                 source: :registration_form,
                 accepted_at: DateTime.utc_now()
               },
               action: :create
             ),
           {:ok, _privacy} <-
             Ash.create(
               VgApp.Accounts.ConsentRecord,
               %{
                 user_id: user.id,
                 consent_type: :privacy_policy,
                 consent_version: privacy_version,
                 source: :registration_form,
                 accepted_at: DateTime.utc_now()
               },
               action: :create
             ),
           {:ok, _maybe_marketing} <- maybe_create_marketing_consent(user, marketing_consent) do
        user
      end
    end)
  end

  defp maybe_create_marketing_consent(user, true) do
    Ash.create(
      VgApp.Accounts.ConsentRecord,
      %{
        user_id: user.id,
        consent_type: :marketing,
        consent_version: "v0",
        source: :registration_form,
        accepted_at: DateTime.utc_now()
      },
      action: :create
    )
  end

  defp maybe_create_marketing_consent(_user, _), do: {:ok, :not_applicable}

  def bootstrap_staff_admin(user_id) do
    Ash.create(
      VgApp.Accounts.AccountRole,
      %{user_id: user_id, role: :staff_admin},
      action: :bootstrap_staff_admin,
      actor: :system
    )
  end

  def assign_role(actor, attrs) when is_map(attrs) do
    Ash.create(VgApp.Accounts.AccountRole, attrs, action: :assign_role, actor: actor)
  end
end
