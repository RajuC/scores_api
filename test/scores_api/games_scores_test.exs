defmodule ScoresApi.GamesScoresTest do
  use ScoresApi.DataCase

  alias ScoresApi.GamesScores


  describe "games_scores" do
    alias ScoresApi.Games
    alias ScoresApi.Users
    alias ScoresApi.Rounds

    @valid_score_attrs1 %{game_score: [%{"name"=> "raj", "score" => 30}, %{"name" => "som", "score" => 0}], players: %{"active" => ["raj", "som"], "inactive" => []}, round_num: 1}
    @valid_score_attrs2 %{game_score: [%{"name"=> "raj", "score" => 0}, %{"name" => "som", "score" => 45}], players: %{"active" => ["raj", "som"], "inactive" => []}, round_num: 2}



    @valid_game_attrs1  %{high_pts_to_win: true, players: ["raj", "somu"], title: "some title"}
    @valid_game_attrs2  %{high_pts_to_win: false, players: ["raj", "somu"], title: "some title1"}
    @create_user_attrs %{email: "email@email.com", name: "some name", password: "some password", password_confirmation: "some password"}



    test "list_games_scores/1 for a user" do
      {:ok, user}     = Users.create_user(@create_user_attrs)
      {:ok, game1}    = Games.create_game(user, @valid_game_attrs1)
      {:ok, game2}    = Games.create_game(user, @valid_game_attrs2)
      {:ok, _round1}  = Rounds.create_round(game1, @valid_score_attrs1)
      {:ok, _round2}  = Rounds.create_round(game1, @valid_score_attrs2)
      g1_rounds       = GamesScores.get_rounds(game1)
      g2_rounds       = GamesScores.get_rounds(game2)
      g1_ts           = GamesScores.calculate_t_s(g1_rounds)
      g2_ts           = GamesScores.calculate_t_s(g2_rounds)
      g1_lp           = GamesScores.get_leading_player(game1.high_pts_to_win, g1_ts)
      g2_lp           = GamesScores.get_leading_player(game2.high_pts_to_win, g2_ts)
      g1_pw           = GamesScores.cal_player_wins(g1_rounds)
      g2_pw           = GamesScores.cal_player_wins(g2_rounds)

      assert [%{
                game_id:                 game1.id,
                high_pts_to_win:         game1.high_pts_to_win,
                title:                   game1.title,
                timestamp:               game1.inserted_at,
                rounds:                  g1_rounds,
                leading_player:          g1_lp,
                total_rounds:            length(g1_rounds),
                total_scores:            g1_ts,
                player_wins:             g1_pw
              },
              %{
                game_id:               game2.id,
                high_pts_to_win:       game2.high_pts_to_win,
                title:                 game2.title,
                timestamp:             game2.inserted_at,
                rounds:                g2_rounds,
                leading_player:        g2_lp,
                total_rounds:          length(g2_rounds),
                total_scores:          g2_ts,
                player_wins:           g2_pw
              }] == GamesScores.list_games_scores(user)
    end
  end
end
