defmodule StandupBotSupervisor do
  use Supervisor

  def start_link([[bot_token, channel, hour, minute, cfg, tmp]]) do
    Supervisor.start_link(__MODULE__, [[bot_token, channel, hour, minute, cfg, tmp]])
  end

  def init([[bot_token, channel, hour, minute, cfg, tmp]]) do
    children = [
      worker(Bot, [[bot_token, channel, hour, minute, cfg, tmp]])
    ]
    supervise(children, strategy: :one_for_one)
  end

end