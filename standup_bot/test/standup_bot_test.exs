defmodule StandupBotTest do
  use ExUnit.Case
  doctest StandupBot

  test "greets the world" do
    assert StandupBot.hello() == :world
  end
end
