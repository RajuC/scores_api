defmodule ScoresApiWeb.Router do
  use ScoresApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do

    # # plug CORSPlug, origin: "http://localhost:8080"
    plug CORSPlug, origin: "*"
    plug :accepts, ["json"]
  end


  pipeline :jwt_authenticated do
    plug ScoresApiWeb.Auth.Pipeline
  end


  scope "/", ScoresApiWeb do
    pipe_through :browser

    get "/", PageController, :index
  end


  scope "/api/v1", ScoresApiWeb do
    pipe_through :api

    options   "/sign_up",             UserController, :options
    options   "/sign_in",             UserController, :options
    options   "/user",                UserController, :options

    post      "/sign_up",             UserController, :create
    post      "/sign_in",             UserController, :sign_in
    get       "/user",                UserController, :show




  end


  # Other scopes may use custom stacks.
  scope "/api/v1", ScoresApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get         "/get_user",        UserController,   :get_user
    resources   "/games",           GameController,   only: [:index, :show, :create]
    resources   "/scores",          ScoreController,  only: [:show, :create]
    get         "/games_scores",    GameController,   :all_games_with_scores


    options   "/get_user",          UserController,   :options
    options   "/games",             GameController,   :options
    options   "/scores",            ScoreController,  :options
    options   "/games_scores",      GameController,   :options

  end
end
