defmodule StandupBot.Tasks.Greenkeeping do
  use GenServer

  @default_idle 5_000

  alias StandupBot.{
    Users,
    Messages
  }

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule_work(state)
    {:ok, state}
  end

  defp schedule_work(state, idle_time \\ @default_idle) do
    Process.send_after(self(), :work, idle_time)
  end

  def handle_info(
        :work,
        %{
          ctr: ctr,
          rtm: rtm,
          hour: hour,
          minute: minute,
          week_days: week_days,
          channel: channel,
          cfg: cfg,
          tmp_dir: tmp_dir,
          gh_token: gh_token,
          job: job
        } = state,
        _opts \\ []
      ) do
    week_of_year = div(Date.day_of_year(DateTime.utc_now()),7)
    cond do
      ctr == 0 -> IO.puts("task #{job} initialized")
      Date.day_of_week(DateTime.utc_now()) in week_days && rem(week_of_year, 2) == 1 -> greenkeeping_time(state)
      true -> :ok
    end

    idle_time = Utils.ms_til_next_action(hour, minute)
    IO.inspect({:ms_idle_til_greenkeeping, idle_time})

    state = Map.update!(state, :ctr, &(&1 + 1))

    schedule_work(state, idle_time)
    {:noreply, state}
  end

  def handle_info(:demand_invoke, state, _opts) do
    greenkeeping_time(state)
    {:noreply, state}
  end

  defp greenkeeping_time(%{
         rtm: rtm,
         hour: hour,
         minute: minute,
         week_days: week_days,
         channel: channel,
         cfg: cfg,
         tmp_dir: tmp_dir,
         gh_token: gh_token,
         job: job
       }) do
    person = Users.pick_without_replacement(cfg, tmp_dir, job)
    pr_links = github_links(gh_token)
    msg = Messages.greenkeeping(person, pr_links)
    IO.inspect({:greenkeeping_time})
    send(rtm, {:message, msg, channel})
  end

  def github_links(gh_token) do
    client = Tentacat.Client.new(%{access_token: gh_token})

    {200, %{"items" => items}, _} =
      Tentacat.Search.issues(client, %{
        "q" =>
          "repo:UrbanCompass/uc-frontend is:pr is:open sort:updated-desc label:Greenkeeping label:\"Agent Home FE\""
      })

    Enum.reduce(items, [], fn x, acc ->
      [{Map.get(x, "html_url"), Map.get(x, "title")} | acc]
    end)
  end
end
