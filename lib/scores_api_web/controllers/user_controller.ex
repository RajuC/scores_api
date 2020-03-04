defmodule ScoresApiWeb.UserController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Users
  alias ScoresApi.Users.User
  alias ScoresApiWeb.Auth.Guardian

  action_fallback ScoresApiWeb.FallbackController

  use PhoenixSwagger


  def swagger_definitions do
     %{
       User:
         swagger_schema do
           title("Users")
           description("A user of the ScoresApi")

         properties do
           name(:string, "User name", required: true)
           email(:string, "Email address", format: :email, required: true)
           password(:string, "Password", required: true)
           password_confirmation(:string, "Password Confirmation", required: true)
         end
       end,

       CreateUserRequest:
         swagger_schema do
           title("CreateUserRequest")
           description("POST body for creating a user")
           property(:user, Schema.ref(:User), "The user Request details")
         end,

       SignInRequest:
         swagger_schema do
           title("UserSigninReq")
           description("POST body for singin user")
           properties do
              email(:string, "Email address", format: :email, required: true)
              password(:string, "User name", required: true)
           end
         end,

       UserResponse:
         swagger_schema do
           title("UserResponse")
           description("Response schema for single user")
           properties do
             user_id(:integer, "User ID")
             email(:string, "Email address", format: :email)
             token(:string, "JWT token")
             inserted_at(:string, "Creation timestamp", format: :datetime)
           end
         end
     }
  end




  swagger_path(:create) do
    post("/api/v1/sign_up")
    summary("Create user")
    description("Creates a new user")
    consumes("application/json")
    produces("application/json")

    parameter(:user, :body, Schema.ref(:CreateUserRequest), "The user details",
      example: %{ user: %{
                  name: "Raj Raj",
                  email: "raj@mail.com",
                  password: "password",
                  password_confirmation: "password"
                }}
    )

    response(201, "User created OK", Schema.ref(:UserResponse),
      example: %{
            email: "raj@email.com",
            token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzY29yZXNfYXBpIiwiZXhwIjoxNTgzMjMzNjgxLCJpYXQiOjE1ODMwNjA4ODEsImlzcyI6InNjb3Jlc19hcGkiLCJqdGkiOiIxMWZiOWE1MC0yNzRmLTRjZTAtYmY4NS03ZGQ2YWQwYzk4MmUiLCJuYmYiOjE1ODMwNjA4ODAsInN1YiI6IjMiLCJ0eXAiOiJhY2Nl",
            user_id: 3,
            inserted_at: "2017-02-08T12:34:55Z"

      }
    )
  end
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("user.json", %{user: user, token: token})
    end
  end



  swagger_path(:sign_in) do
    post("/api/v1/sign_in")
    summary("User Sign in")
    description("Sign in User ")
    consumes("application/json")
    produces("application/json")

    parameter(:user, :body, Schema.ref(:SignInRequest), "The user Sign in details",
      example: %{
                  email: "raj@mail.com",
                  password: "password"
                }
    )

    response(200, "OK", Schema.ref(:UserResponse),
      example: %{
            email: "raj@email.com",
            token: "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzY29yZXNfYXBpIiwiZXhwIjoxNTgzMjMzNjgxLCJpYXQiOjE1ODMwNjA4ODEsImlzcyI6InNjb3Jlc19hcGkiLCJqdGkiOiIxMWZiOWE1MC0yNzRmLTRjZTAtYmY4NS03ZGQ2YWQwYzk4MmUiLCJuYmYiOjE1ODMwNjA4ODAsInN1YiI6IjMiLCJ0eXAiOiJhY2Nl",
            user_id: 3,
            inserted_at: "2017-02-08T12:34:55Z"
      }
    )
  end
  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Users.token_sign_in(email, password) do
      {:ok, user, token} ->
        conn |> render("user.json", %{user: user, token: token})
      _ ->
        {:error, :unauthorized}
    end
  end



  swagger_path(:show) do
    summary("Show User")
    description("Show a user by ID")
    produces("application/json")
    parameter(:id, :path, :integer, "User ID", required: true, example: 3)

    response(200, "OK", Schema.ref(:UserResponse),
      example: %{
          id: 3,
          name: "Raj Raj",
          email: "raj@mail.com",
          inserted_at: "2017-02-08T12:34:55Z"
      }
    )
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    conn |> render("user.json", user: user)
  end



  swagger_path(:get_user) do
    get("/api/v1/get_user")
    summary("Get User")
    description("Show a user by Bearer Token")
    produces("application/json")

    parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")

    response(200, "OK", Schema.ref(:UserResponse),
      example: %{
          id: 3,
          name: "Raj Raj",
          email: "raj@mail.com",
          inserted_at: "2017-02-08T12:34:55Z"
      }
    )
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
