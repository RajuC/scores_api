defmodule ScoresApiWeb.PageControllerTest do
  use ScoresApiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to ScorezCount API!"
  end
end
