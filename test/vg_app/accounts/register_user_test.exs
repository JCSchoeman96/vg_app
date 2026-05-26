defmodule VgApp.Accounts.RegisterUserTest do
  use VgApp.DataCase, async: true

  alias VgApp.Accounts
  alias VgApp.Accounts.{AccountRole, ConsentRecord, UserProfile}
  require Ash.Query

  defp valid_registration_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        email: "person@example.com",
        password: "verysecret123",
        password_confirmation: "verysecret123",
        first_name: "Test",
        last_name: "User",
        phone_number: nil,
        terms_consent_version: "v1",
        privacy_policy_consent_version: "v1",
        marketing_consent: nil
      },
      overrides
    )
  end

  test "terms_and_privacy_consent_required" do
    assert {:error, _} = Accounts.register_user(valid_registration_attrs(%{terms_consent_version: nil}))
    assert {:error, _} = Accounts.register_user(valid_registration_attrs(%{privacy_policy_consent_version: nil}))
  end

  test "marketing_consent_optional_and_separate" do
    {:ok, user} =
      Accounts.register_user(
        valid_registration_attrs(%{email: "no-marketing@example.com", marketing_consent: nil})
      )

    consents =
      ConsentRecord
      |> Ash.Query.filter(user_id: user.id, state: :accepted)
      |> Ash.read!()
      |> Enum.map(& &1.consent_type)

    assert Enum.sort(consents) == [:privacy_policy, :terms]
  end

  test "registers_user_with_required_profile_and_consents" do
    {:ok, user} = Accounts.register_user(valid_registration_attrs(%{email: "full@example.com"}))

    profile =
      UserProfile
      |> Ash.Query.filter(user_id: user.id)
      |> Ash.read_one!()

    assert profile.first_name == "Test"
    assert profile.last_name == "User"

    terms =
      ConsentRecord
      |> Ash.Query.filter(user_id: user.id, consent_type: :terms)
      |> Ash.read_one!()

    privacy =
      ConsentRecord
      |> Ash.Query.filter(user_id: user.id, consent_type: :privacy_policy)
      |> Ash.read_one!()

    assert terms.consent_version == "v1"
    assert privacy.consent_version == "v1"
  end

  test "rejects_duplicate_email" do
    assert {:ok, _user} = Accounts.register_user(valid_registration_attrs())
    assert {:error, _} = Accounts.register_user(valid_registration_attrs())
  end

  test "system_is_not_stored_as_user_role" do
    {:ok, user} = Accounts.register_user(valid_registration_attrs(%{email: "staff@example.com"}))

    assert {:ok, %AccountRole{role: :staff_admin}} = Accounts.bootstrap_staff_admin(user.id)

    assert {:error, _} =
             Ash.create(
               AccountRole,
               %{user_id: user.id, role: :system},
               action: :bootstrap_staff_admin,
               actor: :system
             )
  end

  test "staff_admin_role_required_for_admin_actions" do
    {:ok, staff_admin_user} =
      Accounts.register_user(valid_registration_attrs(%{email: "admin@example.com"}))

    {:ok, normal_user} =
      Accounts.register_user(valid_registration_attrs(%{email: "normal@example.com"}))

    {:ok, target_user} =
      Accounts.register_user(valid_registration_attrs(%{email: "target@example.com"}))

    assert {:ok, _} = Accounts.bootstrap_staff_admin(staff_admin_user.id)

    assert {:error, _} =
             Accounts.assign_role(normal_user, %{user_id: target_user.id, role: :customer})

    assert {:ok, _} =
             Accounts.assign_role(staff_admin_user, %{
               user_id: target_user.id,
               role: :customer,
               granted_by_user_id: staff_admin_user.id
             })
  end
end
