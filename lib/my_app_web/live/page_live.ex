defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  @github_url "https://github.com/93software/do-app-platform-example"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :github_url, @github_url)}
  end
end
