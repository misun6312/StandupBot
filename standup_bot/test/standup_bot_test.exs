defmodule StandupBotTest do
  use ExUnit.Case
  doctest StandupBot

  test "init creates expected state" do
    StandupBot.init(fake_file)
    assert StandupBot.hello() == :world
  end
end
