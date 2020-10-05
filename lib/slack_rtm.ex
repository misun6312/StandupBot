defmodule SlackRtm do
  use Slack

  alias StandupBot.Messages

  def handle_connect(slack, state) do
    IO.puts("Connected as #{slack.me.name}")
    {:ok, state}
  end

  defp action_response(results, message, slack) do
    case results do
      {:error, nil} -> send_message("Invalid command :x:", message.channel, slack)
      _ -> send_message("Done! :white_check_mark:", message.channel, slack)
    end
  end

  def handle_event(message = %{type: "message", text: text, channel: channel}, slack, state) do
    case String.split(text) do
      ["!teambot" | rest] ->
        case rest do
          ["standup"] ->
            Process.send(Elixir.StandupBot.Tasks.Standup, :demand_invoke, [])

          ["greenkeeping"] ->
            Process.send(Elixir.StandupBot.Tasks.Greenkeeping, :demand_invoke, [])

          ["help"] ->
            send_message(Messages.help(), channel, slack)

          _unknown ->
            send_message(Messages.unknown(), channel, slack)
        end

      _other_msg ->
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

  def handle_close(reason, _slack, state), do: {:ok, state}
end
