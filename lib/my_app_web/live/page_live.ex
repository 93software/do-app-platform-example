defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  alias MyApp.FishTank

  @github_url "https://github.com/93software/do-app-platform-example"

  @y_multiplier 48
  @x_multiplier 64

  @impl true
  def mount(_params, _session, socket) do
    {ref, fish_id} = if connected? socket do
      FishTank.subscribe_to_fish()
      FishTank.create_fish(
        y_bounds: [0, div(900, @y_multiplier)],
        x_bounds: [0, div(1400, @x_multiplier)]
      )
    else
      {nil, nil}
    end

    fishes = FishTank.list_fish()
    |> Enum.map(fn fish -> {fish.id, fish} end)
    |> Map.new()

    socket = socket
    |> assign(:ref, ref)
    |> assign(:fish_id, fish_id)
    |> assign(:fishes, fishes)
    |> assign(:github_url, @github_url)

    {:ok, socket}
  end

  @impl true
  def handle_event("move_fish", %{"key" => key}, socket) do
    cond do
      key in ["ArrowUp", "w"] ->
        FishTank.move_fish(socket.assigns.ref, :up)

      key in ["ArrowDown", "s"] ->
        FishTank.move_fish(socket.assigns.ref, :down)

      key in ["ArrowRight", "d"] ->
        FishTank.move_fish(socket.assigns.ref, :right)

      key in ["ArrowLeft", "a"] ->
        FishTank.move_fish(socket.assigns.ref, :left)

      true ->
        :noop
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({action, target_fish}, socket) do
    fishes = case action do
      :create_fish ->
        Map.put(socket.assigns.fishes, target_fish.id, target_fish)

      :move_fish ->
        Map.put(socket.assigns.fishes, target_fish.id, target_fish)

      :delete_fish ->
        Map.delete(socket.assigns.fishes, target_fish.id)
    end

    {:noreply, assign(socket, :fishes, fishes)}
  end

  def fish_style(fish) do
    style_string %{
      top: "#{fish.y * 48}px",
      left: "#{fish.x * 64}px",
      transform: if(fish.direction == :left, do: "rotateY(180deg)", else: "none"),
    }
  end

  def style_string(map) do
    Enum.reduce(map, "", fn {key, value}, style -> style <> "#{key}: #{value}; " end)
  end
end
