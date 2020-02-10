defmodule ScoresApiWeb.UserController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Users
  alias ScoresApi.Users.User

  alias ScoresApiWeb.Auth.Guardian

  action_fallback ScoresApiWeb.FallbackController


  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user, token: token})
    end
  end


  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Users.token_sign_in(email, password) do
      {:ok, user, token} ->
        conn |> render("user.json", %{user: user, token: token})
      _ ->
        {:error, :unauthorized}
    end
  end


  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    conn |> render("user.json", user: user)
  end

  def get_user(conn, _params) do
     user = Guardian.Plug.current_resource(conn)
     conn |> render("user.json", user: user)
  end


  # def update(conn, %{"id" => id, "user" => user_params}) do
  #   user = Users.get_user!(id)
  #
  #   with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
  #     render(conn, "show.json", user: user)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   user = Users.get_user!(id)
  #
  #   with {:ok, %User{}} <- Users.delete_user(user) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
