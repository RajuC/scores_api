defmodule ScoresApiWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ScoresApiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ScoresApiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ScoresApiWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ScoresApiWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :game_not_available_for_user}) do
    IO.inspect("game not found for user")
    conn
    |> put_status(:not_found)
    |> put_view(ScoresApiWeb.ErrorView)
    |> render(:"404")
  end


  def call(conn, {:error, :secret_not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ScoresApiWeb.ErrorView)
    |> render(:"404")
  end

end
