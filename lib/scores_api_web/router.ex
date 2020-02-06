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
    plug :accepts, ["json"]
  end

  scope "/", ScoresApiWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ScoresApiWeb do
    pipe_through :api


    resources "/games",           GameController,  only: [:index, :show, :create]
    resources "/scores",          ScoreController, only: [:show, :create]
    get "/games_scores",          GameController,  :all_games_with_scores

  end
end
