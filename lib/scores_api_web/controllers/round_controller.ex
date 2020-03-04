defmodule ScoresApiWeb.RoundController do
  use ScoresApiWeb, :controller

  alias ScoresApi.Rounds
  alias ScoresApi.Games
  alias ScoresApi.Rounds.Round

  action_fallback ScoresApiWeb.FallbackController

  use PhoenixSwagger

  # def index(conn, _params) do
  #   rounds = Rounds.list_rounds()
  #   render(conn, "index.json", rounds: rounds)
  # end

  def swagger_definitions do
     %{
       Round:
         swagger_schema do
           title("Rounds")
           description("Game Round")

         properties do
           game_id(:integer, "Game ID", required: true)
           round_num(:integer, "Round Number", required: true)
           score(Schema.array(:Score), "scores with name", required: true)
           players(Schema.ref(:Players), "Active and InactivePlayers List", required: true)
         end
       end,

       Score:
        swagger_schema do
         title("Score")
         description("Score")

         properties do
           name(:string, "Name", required: true)
           score(:integer, "Score", required: true)
         end
       end,

       Players:
        swagger_schema do
          title("Players")
          description("Active and Inactive Players")

          properties do
            active(array(:string), "Active Players List", required: true)
            inactive(array(:string), "Inactive Players List", required: true)
          end
        end,


       CreateRoundRequest:
         swagger_schema do
           title("CreateRoundRequest")
           description("POST body for creating a Round for a Game")

           properties do
              game_id(:integer, "game id", required: true)
              round(Schema.ref(:Round), "The Create Round Request details", required: true)
           end

         end,

       RoundResponse:
         swagger_schema do
           title("GameResponse")
           description("Response schema for a single Game")
           properties do
             game_id(:integer, "Game ID")
             id(:integer, "Score ID")
             round_num(:integer, "Round Number")
             score(Schema.array(:Score), "scores with name")
             players(Schema.ref(:Players), "Active and InactivePlayers List")
             inserted_at(:string, "Creation timestamp", format: :datetime)
           end
         end
         # ,

       # GamesResponse:
       #   swagger_schema do
       #     title("GamesReponse")
       #     description("Response schema for multiple games")
       #     property(:data, Schema.array(:GameResponse), "The Games details")
       #   end
     }
  end



  swagger_path(:create) do
    post("/api/v1/rounds")
    summary("Create Round for a Game for an User")
    description("Creates Round for a Game for an User")
    consumes("application/json")
    produces("application/json")
    parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")

    parameter(:round, :body, Schema.ref(:CreateRoundRequest), "The Round details",
      example: %{	game_id: 1,
                  	round: %{
                    	players: %{active: ["somu", "raj"], inactive: [] },
                    	round_num: 1,
                    	score: [%{name: "raj", score: 5},    %{name: "somu", score: 0} ]
                    }
                }
    )

    response(201, "User created OK", Schema.ref(:RoundResponse),
      example: %{
                  data: %{
                      game_id: 1,
                      id: 3,
                      players: %{
                          active: [
                              "somu",
                              "raj"
                          ],
                          inactive: []
                      },
                      round_num: 1,
                      score: [%{name: "raj", score: 5},    %{name: "somu", score: 0} ]
                  }
              }
    )
  end
  def create(conn, %{"game_id" => game_id, "round" => round_params}) do
    game = Games.get_game!(game_id)
    with {:ok, %Round{} = round} <- Rounds.create_round(game, round_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.round_path(conn, :show, round))
      |> render("show.json", round: round)
    end
  end

  swagger_path(:show) do
    summary("Show Round")
    description("Show a Round by ID")
    produces("application/json")
    parameter(:authorization, :header, :string, "Bearer <> JWT Token", required: true, example: "Bearer jwt_token")
    parameter(:id, :path, :integer, "Round ID", required: true, example: 3)

    response(201, "User created OK", Schema.ref(:RoundResponse),
      example: %{
                  data: %{
                      game_id: 1,
                      id: 3,
                      players: %{
                          active: [
                              "somu",
                              "raj"
                          ],
                          inactive: []
                      },
                      round_num: 1,
                      score: [%{name: "raj", score: 5},    %{name: "somu", score: 0} ]
                  }
              }
    )
  end
  def show(conn, %{"id" => id}) do
    round = Rounds.get_round!(id)
    render(conn, "show.json", round: round)
  end

  # def update(conn, %{"id" => id, "round" => round_params}) do
  #   round = Rounds.get_round!(id)
  #
  #   with {:ok, %Round{} = round} <- Rounds.update_round(round, round_params) do
  #     render(conn, "show.json", round: round)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   round = Rounds.get_round!(id)
  #
  #   with {:ok, %Round{}} <- Rounds.delete_round(round) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
