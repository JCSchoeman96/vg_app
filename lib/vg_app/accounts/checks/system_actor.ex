defmodule VgApp.Accounts.Checks.SystemActor do
  use Ash.Policy.SimpleCheck

  @impl true
  def describe(_opts), do: "actor is :system"

  @impl true
  def match?(actor, _context, _opts), do: actor == :system
end
