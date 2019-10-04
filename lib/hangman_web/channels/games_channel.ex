defmodule HangmanWeb.GamesChannel do
  use HangmanWeb, :channel

  alias Hangman.Game
  alias Hangman.BackupAgent
  alias Hangman.GameServer

  def join("games:" <> name, payload, socket) do
    if authorized?(payload) do
      GameServer.start(name)
      game = GameServer.peek(name)
      BackupAgent.put(name, game)
      socket = socket
      |> assign(:name, name)
      {:ok, %{"join" => name, "game" => Game.client_view(game)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("guess", %{"letter" => ll}, socket) do
    name = socket.assigns[:name]
    game = GameServer.guess(name, ll)
    broadcast!(socket, "update", %{ "game" => Game.client_view(game) })
    {:reply, {:ok, %{ "game" => Game.client_view(game)}}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
