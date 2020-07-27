defmodule Bot do
  use GenServer

  alias StandupBot.{
    Users,
    Messages,
  }

  def start_link([bot_token, channel, hour, minute, cfg, tmp]) do
    GenServer.start_link(__MODULE__, [bot_token, channel, hour, minute, cfg, tmp])
  end

  def init([bot_token, channel, hour, minute, cfg, tmp]) do
    {:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], bot_token)
    daily_loop(0, rtm, channel, hour, minute, cfg, tmp)
  end

  defp daily_loop(ctr, rtm, channel, hour, minute, cfg, tmp) do
    case { ctr, Date.day_of_week(DateTime.utc_now()) } do
      {0, _} -> IO.inspect {:init, Users.teamlist(:users)}
      {_, 6} -> nil # Saturday
      {_, 7} -> nil # Sunday
      {_, _} -> standup_time(rtm, hour, minute, channel, cfg, tmp)
    end
    idle_time = Utils.ms_til_next_standup(hour, minute)
    IO.inspect {:idle_time, idle_time}
    Process.sleep(idle_time)
    daily_loop(ctr + 1, rtm, channel, hour, minute, cfg, tmp)
  end

  defp pick_starter(cfg, tmp) do
    person = Users.pick_starter(cfg, tmp)
    IO.inspect({:starter, person})
    Messages.start_standup(person, Enum.random(["left", "right"]))
  end

  defp standup_time(rtm, hour, minute, channel, cfg, tmp) do
    send rtm, {:message, pick_starter(cfg, tmp), channel}
  end

end