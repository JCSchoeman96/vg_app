defmodule VgApp.Accounts.Changes.SetGrantedAtNow do
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.change_attribute(changeset, :granted_at, DateTime.utc_now())
  end
end
