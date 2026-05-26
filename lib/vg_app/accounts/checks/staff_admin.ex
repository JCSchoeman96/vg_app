defmodule VgApp.Accounts.Checks.StaffAdmin do
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_opts) do
    "actor has an active staff_admin AccountRole"
  end

  @impl true
  def match?(_actor, nil, _opts), do: false
  def match?(nil, _context, _opts), do: false

  def match?(actor, _context, _opts) do
    case Ash.load(actor, :account_roles, authorize?: false) do
      {:ok, actor_with_roles} ->
        Enum.any?(actor_with_roles.account_roles, fn role ->
          role.role == :staff_admin and role.state == :active
        end)

      _ ->
        false
    end
  end
end
