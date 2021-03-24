defmodule MyApp.Fish do
  def create(id, opts \\ []) do
    [x_lower, x_upper] = Keyword.get(opts, :x_bounds, [0, 10])
    [y_lower, y_upper] = Keyword.get(opts, :y_bounds, [0, 10])

    %{
      id: id,
      x: Enum.random(x_lower..x_upper),
      y: Enum.random(y_lower..y_upper),
      direction: if(Enum.random(0..1) == 0, do: :right, else: :left),
    }
  end

  def move(fish, :up) do
    %{fish | y: fish.y - 1}
  end

  def move(fish, :down) do
    %{fish | y: fish.y + 1}
  end

  def move(fish, :right) do
    %{fish | x: fish.x + 1, direction: :right}
  end

  def move(fish, :left) do
    %{fish | x: fish.x - 1, direction: :left}
  end
end
