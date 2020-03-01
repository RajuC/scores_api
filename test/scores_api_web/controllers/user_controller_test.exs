defmodule ScoresApiWeb.UserControllerTest do
  use ScoresApiWeb.ConnCase

  alias ScoresApi.Users
  # alias ScoresApi.Users.User

  @create_attrs %{
    email: "email@email.com",
    name: "some name",
    password: "some password",
    password_confirmation: "some password"
  }

  @sign_in_attrs %{
    email: "email@email.com",
    password: "some password",
  }

  @invalid_sign_in_attrs %{
    email: "email@email.com",
    password: "invalid password",
  }

  # @update_attrs %{
  #   email: "some updated email",
  #   name: "some updated name",
  #   password_hash: "some updated password_hash"
  # }

  @invalid_attrs %{email: nil, name: nil, password_hash: nil}


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "create user and show " do
    test "renders user when sign_up data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{
               "user_id"    => id,
               "email"      => email,
               "token"      => token} = json_response(conn, 201)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id"         => id,
               "email"      => email,
               "name"       => name} = json_response(conn, 200)
    end

    test "renders errors when sign_up data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

  end



  describe "sign_in and get_user" do
    test "renders user when sign_in data is valid", %{conn: conn} do
      {:ok, _user} = Users.create_user(@create_attrs)
      conn1 = post(conn, Routes.user_path(conn, :sign_in), @sign_in_attrs)
      assert %{"user_id" => id, "email" => email, "token" => token} = json_response(conn1, 200)
      conn =
        conn
          |> bypass_through(PhoenixTestSession.Router, [:api, :jwt_authenticated])
          |> put_req_header("authorization", "Bearer " <> token)
          |> get(Routes.user_path(conn, :get_user))

      assert %{
               "id"       => id,
               "email"    => email,
               "name"     => name
             } = json_response(conn, 200)
    end

    test "renders user when sign_in data is invalid", %{conn: conn} do
      {:ok, _user} = Users.create_user(@create_attrs)
      conn1 = post(conn, Routes.user_path(conn, :sign_in), @invalid_sign_in_attrs)
      assert json_response(conn1, 401)["errors"] == %{"detail" => "Not Found"}
    end
  end



  # describe "update user" do
  #   setup [:create_user]
  #
  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]
  #
  #     conn = get(conn, Routes.user_path(conn, :show, id))
  #
  #     assert %{
  #              "id" => id,
  #              "email" => "some updated email",
  #              "name" => "some updated name",
  #              "password_hash" => "some updated password_hash"
  #            } = json_response(conn, 200)["data"]
  #   end
  #
  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]
  #
  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.user_path(conn, :delete, user))
  #     assert response(conn, 204)
  #
  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.user_path(conn, :show, user))
  #     end
  #   end
  # end
  #
  # defp create_user(_) do
  #   user = fixture(:user)
  #   {:ok, user: user}
  # end
end
