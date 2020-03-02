defmodule ScoresApiWeb.Router do
  use ScoresApiWeb, :router

  pipeline :api do
    # # plug CORSPlug, origin: "http://localhost:8080"
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug ScoresApiWeb.Auth.Pipeline
  end





  scope "/api/v1", ScoresApiWeb do
    pipe_through :api

    options   "/sign_up",             UserController, :options
    options   "/sign_in",             UserController, :options
    options   "/users",                UserController, :options

    post      "/sign_up",             UserController, :create
    post      "/sign_in",             UserController, :sign_in
    resources "/users",               UserController, only: [:show]

  end


  # Other scopes may use custom stacks.
  scope "/api/v1", ScoresApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get         "/get_user",        UserController,   :get_user
    resources   "/games",           GameController,   only: [:index, :show, :create]
    resources   "/rounds",          RoundController,  only: [:show,  :create]
    get         "/games_scores",    GameController,   :all_games_with_scores


    options   "/get_user",          UserController,   :options
    options   "/games",             GameController,   :options
    options   "/rounds",            RoundController,  :options
    options   "/games_scores",      GameController,   :options

  end

  scope "/" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :scores_api, swagger_file: "swagger.json"
  end



  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "ScorezCount API"
        # host: "http://scorezcount.com:4000"
      },
      schemes: ["http"]
    #   ,
    #   securityDefinitions: %{
    #   Bearer: %{
    #     type: "apiKey",
    #     name: "Authorization",
    #     in: "header"
    #   }
    # }
    }
  end


  # basePath: "/api",
  #   info: %{..},
  #   tags: [%{name: "Users", description: "Operations about Users"}]


end
