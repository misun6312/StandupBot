defmodule StandupBot.CLI do

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

    %{
      "bot_user_oauth_access_token" => bot_token,
      "users"                       => default_users,
    } = Utils.read_json_file(config_file)

    # Create users agent state store + register pid
    {:ok, users_pid} = Users.start_link([])
    Process.register(users_pid, :users)
    Users.enroll_users(:users, default_users)

    # Start supervisor
    Process.sleep(4000)
    StandupBotSupervisor.start_link([[bot_token, channel, hour, minute]])
  end

end
