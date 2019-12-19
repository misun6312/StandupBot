defmodule StandupBotSupervisor do
  use Supervisor

  def start_link([[bot_token, channel, hour, minute]]) do
    Supervisor.start_link(__MODULE__, [[bot_token, channel, hour, minute]])
  end

  def init([[bot_token, channel, hour, minute]]) do
    children = [
      worker(Bot, [[bot_token, channel, hour, minute]])
    ]
    supervise(children, strategy: :one_for_one)
  end

end