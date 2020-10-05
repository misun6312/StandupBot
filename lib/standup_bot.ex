defmodule StandupBot do
  use Supervisor

  alias StandupBot.Tasks.{
    Standup,
    Greenkeeping
  }

  def start_link([config, bot_token, tmp_dir, tasks]) do
    GenServer.start_link(__MODULE__, [config, bot_token, tmp_dir, tasks])
  end

  def init([config, bot_token, tmp_dir, tasks]) do
    {:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], bot_token)

    children = []

    # Add standup job if specified
    children =
      if Map.has_key?(tasks, "standup") do
        [
          worker(Standup, [
            %{
              job: "standup",
              ctr: 0,
              rtm: rtm,
              channel: get_in(tasks, ["standup", "channel"]),
              hour: get_in(tasks, ["standup", "hour"]),
              minute: get_in(tasks, ["standup", "minute"]),
              week_days: get_in(tasks, ["standup", "week_days"]),
              cfg: config,
              tmp_dir: tmp_dir
            }
          ])
          | children
        ]
      else
        children
      end

    # Add greenkeeping job if specified
    children =
      if Map.has_key?(tasks, "greenkeeping") do
        [
          worker(Greenkeeping, [
            %{
              job: "greenkeeping",
              ctr: 0,
              rtm: rtm,
              channel: get_in(tasks, ["greenkeeping", "channel"]),
              hour: get_in(tasks, ["greenkeeping", "hour"]),
              minute: get_in(tasks, ["greenkeeping", "minute"]),
              week_days: get_in(tasks, ["greenkeeping", "week_days"]),
              cfg: config,
              tmp_dir: tmp_dir,
              gh_token: get_in(tasks, ["greenkeeping", "github_token"])
            }
          ])
          | children
        ]
      else
        children
      end

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
