defmodule StandupBot.Tasks.Standup do
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
          job: job
        } = state,
        _opts \\ []
      ) do
    cond do
      ctr == 0 -> IO.puts("task #{job} initialized")
      Date.day_of_week(DateTime.utc_now()) in week_days -> standup_time(state)
      true -> :ok
    end

    idle_time = Utils.ms_til_next_action(hour, minute)
    IO.inspect({:ms_idle_til_standup, idle_time})

    state = Map.update!(state, :ctr, &(&1 + 1))

    schedule_work(state, idle_time)
    {:noreply, state}
  end

  def handle_info(:demand_invoke, state, _opts) do
    standup_time(state)
    {:noreply, state}
  end

  defp standup_time(%{
         ctr: ctr,
         rtm: rtm,
         hour: hour,
         minute: minute,
         week_days: week_days,
         channel: channel,
         cfg: cfg,
         tmp_dir: tmp_dir,
         job: job
       }) do
    person = Users.pick_without_replacement(cfg, tmp_dir, job)
    direction = Enum.random(["left", "right"])
    msg = Messages.start_standup(person, direction)
    IO.inspect({:standup})
    send(rtm, {:message, msg, channel})
  end
end
