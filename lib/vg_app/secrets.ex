defmodule VgApp.Secrets do
  use AshAuthentication.Secret

  def secret_for(
        [:authentication, :tokens, :signing_secret],
        VgApp.Accounts.User,
        _opts,
        _context
      ) do
    Application.fetch_env(:vg_app, :token_signing_secret)
  end
end
