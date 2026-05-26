defmodule VgApp.Repo do
  use Ecto.Repo,
    otp_app: :vg_app,
    adapter: Ecto.Adapters.Postgres
end
