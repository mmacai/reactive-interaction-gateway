defmodule GatewayWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest
      alias GatewayWeb.Presence.Channel, as: PresenceChannel


      # The default endpoint for testing
      @endpoint GatewayWeb.Endpoint

      # Roles definitions
      @support_role "support"
      @customer_role "customer"

      # Generic subscribe and join function to channels
      def subscribe_and_join_user(username, roles, topic) do
        token_info_customer = %{"username" => username, "role" => roles, "jti" => "abc123"}
        socket("", %{user_info: token_info_customer})
        |> subscribe_and_join(PresenceChannel, topic)
      end
    end
  end

  setup do

    :ok
  end
end
