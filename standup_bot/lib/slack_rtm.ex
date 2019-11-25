defmodule SlackRtm do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  defp action_response(results, message, slack) do
    IO.inspect({:results, results})
    send_message("Done! :white_check_mark:", message.channel, slack)
  end

  def handle_event(message = %{type: "message", text: text}, slack, state) do
    IO.inspect message
    tokens = String.split(message.text)
    [first | rest] = tokens
    if first == "!standup" do
      case rest do
        ["enroll" | users]   ->
          StandupBot.Users.enroll_users(:users, Utils.validate_users(users))
          |> action_response(message, slack)
        ["unenroll" | users] ->
          StandupBot.Users.unenroll_users(:users, Utils.validate_users(users))
          |> action_response(message, slack)
        ["list"]             ->
          send_message("Not implemented", message.channel, slack)
        unknown               ->
          send_message("Unknown command", message.channel, slack)
      end
    else
      :ok
    end

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)
    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end
