defmodule MyApp.FishTank do
  use GenServer

  require Logger

  alias MyApp.Fish

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def create_fish(opts \\ []) do
    GenServer.call(__MODULE__, {:create_fish, opts})
  end

  def list_fish() do
    GenServer.call(__MODULE__, :list_fish)
  end

  def move_fish(ref, direction) do
    GenServer.cast(__MODULE__, {:move_fish, ref, direction})
  end

  def subscribe_to_fish() do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "fish")
  end

  defp broadcast(message) do
    Phoenix.PubSub.broadcast(MyApp.PubSub, "fish", message)
  end

  @impl true
  def init(_arg) do
    Logger.info("Started FishTank server")
    {:ok, {0, %{}}}
  end

  @impl true
  def handle_call({:create_fish, opts}, {pid, _ref}, {next_id, fishes}) do
    ref = Process.monitor(pid)
    new_fish = Fish.create(next_id, opts)

    fishes = Map.put(fishes, ref, new_fish)

    broadcast({:create_fish, new_fish})

    {:reply, {ref, next_id}, {next_id + 1, fishes}}
  end

  @impl true
  def handle_call(:list_fish, _from, {next_id, fishes}) do
    {:reply, Map.values(fishes), {next_id, fishes}}
  end

  @impl true
  def handle_cast({:move_fish, ref, direction}, {next_id, fishes}) do
    if target_fish = Map.get(fishes, ref) do
      target_fish = Fish.move(target_fish, direction)

      broadcast({:move_fish, target_fish})

      {:noreply, {next_id, Map.put(fishes, ref, target_fish)}}
    else
      {:noreply, {next_id, fishes}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, {:shutdown, :closed}}, {next_id, fishes}) do
    if target_fish = Map.get(fishes, ref) do
      broadcast({:delete_fish, target_fish})
    end

    {:noreply, {next_id, Map.delete(fishes, ref)}}
  end
end
