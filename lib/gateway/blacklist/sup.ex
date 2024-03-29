defmodule Gateway.Blacklist.Sup do
  @moduledoc """
  Supervisor for the global Blacklist.

  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @impl Supervisor
  def init(:ok) do
    children = [
      # The PresenceHandler also starts the Blacklist server. Since that's kind
      # of hard to guess, this supervisor exists to hide this implementation
      # detail to the parent supervisor.
      worker(Gateway.Blacklist.PresenceHandler, _args = [[pubsub_server: Gateway.PubSub]]),
    ]
    supervise(children, strategy: :one_for_one)
  end
end
