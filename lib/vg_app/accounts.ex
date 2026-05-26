defmodule VgApp.Accounts do
  use Ash.Domain,
    otp_app: :vg_app

  resources do
    resource VgApp.Accounts.Token
    resource VgApp.Accounts.User
  end
end
