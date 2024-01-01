defmodule SiliconTest do
  use ExUnit.Case
  doctest Silicon

  test "greets the world" do
    assert Silicon.hello() == :world
  end
end
