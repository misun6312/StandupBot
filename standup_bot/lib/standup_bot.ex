defmodule StandupBot do
  use Supervisor

  alias StandupBot.Tasks.{
    Standup,
    Greenkeeping
  }

  def start_link([config, bot_token, gh_token, tmp_dir, jobs]) do
    GenServer.start_link(__MODULE__, [config, bot_token, gh_token, tmp_dir, jobs])
  end

  def init([config, bot_token, gh_token, tmp_dir, jobs]) do
    {:ok, rtm} = Slack.Bot.start_link(SlackRtm, [], bot_token)

    children = [
      worker(Standup, [
        %{
          job: "standup",
          ctr: 0,
          rtm: rtm,
          channel: get_in(jobs, ["standup", "channel"]),
          hour: get_in(jobs, ["standup", "hour"]),
          minute: get_in(jobs, ["standup", "minute"]),
          week_days: get_in(jobs, ["standup", "week_days"]),
          cfg: config,
          tmp_dir: tmp_dir
        }
      ]),
      worker(Greenkeeping, [
        %{
          job: "greenkeeping",
          ctr: 0,
          rtm: rtm,
          channel: get_in(jobs, ["greenkeeping", "channel"]),
          hour: get_in(jobs, ["greenkeeping", "hour"]),
          minute: get_in(jobs, ["greenkeeping", "minute"]),
          week_days: get_in(jobs, ["greenkeeping", "week_days"]),
          cfg: config,
          tmp_dir: tmp_dir,
          gh_token: gh_token
        }
      ])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
