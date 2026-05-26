defmodule VgAppWeb.PageController do
  use VgAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
