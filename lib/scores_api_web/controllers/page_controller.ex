defmodule ScoresApiWeb.PageController do
  use ScoresApiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
