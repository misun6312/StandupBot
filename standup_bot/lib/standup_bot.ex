defmodule StandupBot do
  alias StandupBot.{
    Users,
    Messages,
  }

  @doc """
  Entry point of the program. Parse args plus start initialize
  """
  def main(args \\ []) do
    [channel, [hour, minute], config_file] = case args do
      [channel, time, config_file] -> [
        "#" <> channel,
        String.split(time, ":")
        |> IO.inspect()
        |> Enum.map(&String.to_integer/1),
        config_file
      ]
      _ -> IO.puts "Error: Need arguments for channel (ex `standup`) and time (ex `10:45`)"
    end
    rtm = init(config_file)
    Process.sleep(4000)
    daily_loop(0, rtm, channel, hour, minute)
  end


  @doc """
  Initialize program with necessary processes and tokens
  """
  def init(config_file) do
    %{
      "bot_user_oauth_access_token" => bot_token,
      "users"                       => default_users,
    } = Utils.read_json_file(config_file)

    {:ok, users_pid} = Users.start_link([])
    Process.register(users_pid, :users)
    Users.enroll_users(:users, default_users)

    case Slack.Bot.start_link(SlackRtm, [], bot_token) do
      {:ok, rtm}        -> rtm
      {:error, _reason} -> :error
    end
  end


  defp daily_loop(ctr, rtm, channel, hour, minute) do
    case { ctr, Date.day_of_week(DateTime.utc_now()) } do
      {0, _}        -> IO.inspect {:init, Users.teamlist(:users)} #send_message(rtm, StandupBot.Messages.init(hour, minute), channel)
      {_, 6}        -> nil # Saturday
      {_, 7}        -> nil # Sunday
      {_, _weekday} -> send_message(rtm, pick_starter(hour, minute), channel)
    end
    idle_time = Utils.ms_til_next_standup(hour, minute)
    IO.inspect {:idle_time, idle_time}
    Process.sleep(idle_time)
    daily_loop(ctr + 1, rtm, channel, hour, minute)
  end


  defp send_message(rtm, message, channel) do
    send rtm, {:message, message, channel}
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
