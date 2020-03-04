defmodule ScoresApiWeb.GameController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Games
  alias ScoresApi.GamesScores
  alias ScoresApi.Games.Game

  action_fallback ScoresApiWeb.FallbackController

  use PhoenixSwagger



  def swagger_definitions do
     %{
       Game:
         swagger_schema do
           title("Games")
           description("Users Game")

         properties do
           title(:string, "Game name", required: true)
           high_pts_to_win(:boolean, "false", required: true)
           players(array(:string), "Players List", required: true)
         end
       end,

       CreateGameRequest:
         swagger_schema do
           title("CreateGameRequest")
           description("POST body for creating a Game for a User")
           property(:game, Schema.ref(:Game), "The Create Game Request details")
         end,

       GameResponse:
         swagger_schema do
           title("GameResponse")
           description("Response schema for a single Game")
           properties do
             game_id(:integer, "Game ID")
             players(array(:string), "Players List")
             title(:string, "Game Title")
             high_pts_to_win(:boolean, "false")
             inserted_at(:string, "Creation timestamp", format: :datetime)
           end
         end,

       GamesResponse:
         swagger_schema do
           title("GamesReponse")
           description("Response schema for multiple games")
           property(:data, Schema.array(:GameResponse), "The Games details")
         end,


       PlayerWins:
        swagger_schema do
         title("PlayerWins")
         description("Num of Player Wins")

         properties do
           name(:string, "Name")
           winning_rounds(:integer, "Num of winning rounds")
         end
       end,

       RoundScore:
        swagger_schema do
         title("RoundScore")
         description("Round Score")

         properties do
           round_num(:integer, "Round Number")
           score(Schema.array(:Score), "scores with name")
           time(:string, "Round Creation timestamp", format: :datetime)
         end
       end,


      GameScore:
       swagger_schema do
        title("GameScore")
        description("Response schema for a Game Score")
        properties do
          game_id(:integer, "Game ID")
          title(:string, "Game Title")
          high_pts_to_win(:boolean, "false")
          total_rounds(:integer, "Total Rounds")
          leading_player(Schema.ref(:Score), "Leading player with score")
          player_wins(Schema.array(:PlayerWins), "No of player_wins with a name")
          rounds(Schema.array(:RoundScore), "Round Scores of a game")
          timestamp(:string, "Game Creation timestamp", format: :datetime)
          total_scores(Schema.array(:Score), "Total Scores for a player of a Game")

        end
      end,

      GamesScores:
       swagger_schema do
        title("GamesScores")
        description("Response schema for GamesScores for an user")
        property(:data, Schema.array(:GameScore), "All GamesScores for an user")
      end


     }
  end




  swagger_path(:index) do
      get("/api/v1/games")
      summary("List Games for a User")
      description("List all games for an User in the database")
      produces("application/json")
      parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")

      response(200, "OK", Schema.ref(:GamesResponse),
        example: [
                    %{
                        high_pts_to_win: false,
                        game_id: 1,
                        players: [
                            "raj",
                            "raj1"
                        ],
                        title: "Rummy",
                        inserted_at: "2017-02-08T12:34:55Z"
                    },
                    %{
                        high_pts_to_win: true,
                        game_id: 2,
                        players: [
                            "raj",
                            "raj1"
                        ],
                        title: "Rummy1",
                        inserted_at: "2017-02-08T12:34:55Z"
                    }
                ]
      )
    end

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = Games.list_games(user)
    render(conn, "index.json", games: games)
  end



  swagger_path(:all_games_with_scores) do
      get("/api/v1/games_scores")
      summary("List Games Scores for a User")
      description("List all games with scores for an User in the database")
      produces("application/json")
      parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")

      response(200, "OK", Schema.ref(:GamesScores),
        example: [
                    %{
                        game_id: 1,
                        high_pts_to_win: false,
                        leading_player: %{},
                        player_wins: [],
                        rounds: [],
                        timestamp: "2020-03-01T08:30:34",
                        title: "Rummy",
                        total_rounds: 0,
                        total_scores: []
                    },
                    %{
                        game_id: 2,
                        high_pts_to_win: false,
                        leading_player: %{},
                        player_wins: [],
                        rounds: [],
                        timestamp: "2020-03-01T08:30:34",
                        title: "Rummy",
                        total_rounds: 0,
                        total_scores: []
                    }
                ]
      )
    end

  def all_games_with_scores(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    games = GamesScores.list_games_scores(user)
    render(conn, "g_s_index.json", games: games)
  end


  swagger_path(:create) do
    post("/api/v1/games")
    summary("Create Game for an User")
    description("Creates Game for an User")
    consumes("application/json")
    produces("application/json")
    parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")

    parameter(:game, :body, Schema.ref(:CreateGameRequest), "The Game details",
      example: %{ game: %{
                  title: "Rummy",
                  high_pts_to_win: true,
                  players: ["Raj", "Raj1"]
                }}
    )

    response(201, "Game created OK", Schema.ref(:GameResponse),
      example: %{
          high_pts_to_win: true,
          game_id: 2,
          players: [
              "raj",
              "raj1"
          ],
          title: "Rummy1",
          inserted_at: "2017-02-08T12:34:55Z"
      }
    )
  end
  def create(conn, %{"game" => game_params}) do
    user = Guardian.Plug.current_resource(conn)
    with {:ok, %Game{} = game} <- Games.create_game(user, game_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end



  swagger_path(:show) do
    summary("Show Game")
    description("Show a Game by ID")
    produces("application/json")
    parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")
    parameter(:id, :path, :integer, "Game ID", required: true, example: 3)

    response(200, "OK", Schema.ref(:GameResponse),
      example: %{
          high_pts_to_win: true,
          game_id: 2,
          players: [
              "raj",
              "raj1"
          ],
          title: "Rummy1",
          inserted_at: "2017-02-08T12:34:55Z"
      }
    )
  end
  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    render(conn, "show.json", game: game)
  end

  # def update(conn, %{"id" => id, "game" => game_params}) do
  #   game = Games.get_game!(id)
  #
  #   with {:ok, %Game{} = game} <- Games.update_game(game, game_params) do
  #     render(conn, "show.json", game: game)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   game = Games.get_game!(id)
  #
  #   with {:ok, %Game{}} <- Games.delete_game(game) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
