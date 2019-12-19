defmodule Bot do
  use GenServer

  alias StandupBot.{
    Users,
    Messages,
  }

  def start_link([bot_token, channel, hour, minute]) do
    GenServer.start_link(__MODULE__, [bot_token, channel, hour, minute])
  end

  def init([bot_token, channel, hour, minute]) do
    {:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], bot_token)
    daily_loop(0, rtm, channel, hour, minute)
  end

  defp daily_loop(ctr, rtm, channel, hour, minute) do
    case { ctr, Date.day_of_week(DateTime.utc_now()) } do
      {0, _} -> IO.inspect {:init, Users.teamlist(:users)}
      {_, 6} -> nil # Saturday
      {_, 7} -> nil # Sunday
      {_, _} -> send rtm, {:message, pick_starter(hour, minute), channel}
    end
    idle_time = Utils.ms_til_next_standup(hour, minute)
    IO.inspect {:idle_time, idle_time}
    Process.sleep(idle_time)
    daily_loop(ctr + 1, rtm, channel, hour, minute)
  end

  defp pick_starter(hour, minute) do
    persons = Users.teamlist(:users)
    directions = ["left", "right"]
    case length(persons) do
      0 -> Messages.no_users(hour, minute)
      _ -> Messages.start_standup(Enum.random(persons), Enum.random(directions))
    end
  end

end