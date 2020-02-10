defmodule ScoresApiWeb.UserView do
  use ScoresApiWeb, :view
  # alias ScoresApiWeb.UserView

  # def render("index.json", %{users: users}) do
  #   %{data: render_many(users, UserView, "user.json")}
  # end
  #
  # def render("show.json", %{user: user}) do
  #   %{data: render_one(user, UserView, "user.json")}
  # end

  def render("user.json", %{user: user, token: token}) do
    %{
      user_id: user.id,
      email: user.email,
      token: token,
    }
  end


  def render("user.json", %{user: user}) do
    %{id: user.id,
      email: user.email,
      name:  user.name}
  end

end
