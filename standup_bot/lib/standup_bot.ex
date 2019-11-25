defmodule StandupBot do

  def main(args \\ []) do
    [channel, [hour, minute]] = case args do
      [channel, time] -> [
        "#" <> channel,
        String.split(time, ":")
        |> IO.inspect()
        |> Enum.map(&String.to_integer/1)
      ]
      _ -> IO.puts "Error: Need arguments for channel (ex `standup`) and time (ex `10:45`)"
    end
    rtm = init()
    Process.sleep(4000)
    daily_loop(rtm, channel, hour, minute)
  end

  def init do
    bot_token = Utils.fetch_creds() |> Map.fetch!("bot_user_oauth_access_token")
    {:ok, users_pid} = StandupBot.Users.start_link([])
    Process.register(users_pid, :users)
    case Slack.Bot.start_link(SlackRtm, [], bot_token) do
      {:ok, rtm}        -> rtm
      {:error, _reason} -> :error
    end
  end

  def daily_loop(rtm, channel, hour, minute) do
    case Date.day_of_week(DateTime.utc_now()) do
      6       -> nil # Saturday
      7       -> nil # Sunday
      _weekday -> send_message(rtm, pick_starter(hour, minute), channel)
    end
    idle_time = Utils.ms_til_next_standup(hour, minute)
    IO.inspect idle_time
    Process.sleep(idle_time)
    daily_loop(rtm, channel, hour, minute)
  end

  def send_message(rtm, message, channel) do
    send rtm, {:message, message, channel}
  end

  def pick_starter(hour, minute) do
    persons = StandupBot.Users.teamlist(:users)
    directions = ["left", "right"]
    case length(persons) do
      0 -> "Standup at #{hour}:#{minute} (enroll teammates via `!standup enroll @teammate1 @teammate2...`"
      _ -> "Standup at #{hour}:#{minute} <@#{Enum.random(persons)}> starts - moves to their #{Enum.random(directions)}"
    end
  end

end
