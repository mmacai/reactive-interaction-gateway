# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config


# --------------------------------------
# Logger
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:module, :request_id]


# --------------------------------------
# Phoenix
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

config :gateway, GatewayWeb.Endpoint,
  url: [
    host: {:system, "HOST", "localhost"}
  ],
  http: [
    port: {:system, :integer, "PORT", 4000},
    acceptors: 100, # less is better, had 10_000 before
    max_connections: :infinity, # had 100_000 before
    protocol_options: [max_keepalive: 100] # had 100_000 before
  ],
  render_errors: [view: GatewayWeb.ErrorView, accepts: ~w(html json xml)],
  pubsub: [name: Gateway.PubSub, adapter: Phoenix.PubSub.PG2]


# --------------------------------------
# API Gateway (Proxy)
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

config :gateway, Gateway.Proxy,
  config_file: {:system, "PROXY_CONFIG_FILE", nil}
config :gateway, GatewayWeb.Proxy.Controller,
  gateway_proxy: Gateway.Proxy

config :gateway, Gateway.RateLimit,
  # Internal ETS table name (must be unique).
  table_name: :rate_limit_buckets,
  # Enables/disables rate limiting globally.
  enabled?: {:system, :boolean, "RATE_LIMIT_ENABLED", false},
  # If true, the remote IP is taken into account; otherwise the limits are per endpoint only.
  per_ip?: {:system, :boolean, "RATE_LIMIT_PER_IP", true},
  # The permitted average amount of requests per second.
  avg_rate_per_sec: {:system, :integer, "RATE_LIMIT_AVG_RATE_PER_SEC", 50},
  # The permitted peak amount of requests.
  burst_size: {:system, :integer, "RATE_LIMIT_BURST_SIZE", 100},
  # GC interval. If set to zero, GC is disabled.
  sweep_interval_ms: {:system, :integer, "RATE_LIMIT_SWEEP_INTERVAL_MS", 5_000}


# --------------------------------------
# User Roles
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# A connection is only considered a "session" if the user is member of the `session_role` as
# defined here and stated in the JWT. For example, if you need a system user that should not show
# up when listing active users, just make sure the user does not assume the session role.
session_role = {:system, "SESSION_ROLE", "user"}

# Users that belong to a privileged role are allowed to subscribe to messages of any user. Role
# names are case-sensitive. By default, there are no privileged roles.
# For example, to allow all users in the "admin" and "support" groups to subscribe to any
# messages, you could use start RIG with `PRIVILEGED_ROLES=admin,support`.
privileged_roles = {:system, :list, "PRIVILEGED_ROLES", []}


# --------------------------------------
# Kafka
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Kafka JSON message fields:
kafka_message_field_map = %{
  # Name of the JSON property holding the user ID of the recipient:
  user: {:system, "KAFKA_USER_FIELD", "user"}
}

brod_client_id = :gateway_brod_client

config :gateway, Gateway.Kafka,
  brod_client_id: brod_client_id,
  log_topic: {:system, "KAFKA_LOG_TOPIC", "rig"}

config :gateway, Gateway.Kafka.GroupSubscriber,
  brod_client_id: brod_client_id,
  consumer_group: {:system, "KAFKA_CONSUMER_GROUP", "rig-consumer-group"},
  source_topics: {:system, :list, "KAFKA_SOURCE_TOPICS", ["rig"]}

config :gateway, Gateway.Kafka.MessageHandler,
  message_user_field: kafka_message_field_map.user,
  user_channel_name_mf: {GatewayWeb.Presence.Channel, :user_channel_name}

config :gateway, Gateway.Kafka.SupWrapper,
  message_user_field: kafka_message_field_map.user,
  enabled?: {:system, :boolean, "KAFKA_ENABLED", true}

config :gateway, Gateway.Kafka.Sup,
  brod_client_id: brod_client_id,
  hosts: {:system, :list, "KAFKA_HOSTS", ["localhost:9092"]}


# --------------------------------------
# Authorization Token (JWT)
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# JWT payload fields:
jwt_payload_field_map = %{
  # The claim holding the user ID:
  user: {:system, "JWT_USER_FIELD", "user"},
  # The claim holding the user's roles:
  roles: {:system, "JWT_ROLES_FIELD", "roles"}
}

config :gateway, Gateway.Utils.Jwt,
  secret_key: {:system, "JWT_SECRET_KEY", ""}

config :gateway, Gateway.Blacklist,
  default_expiry_hours: {:system, :integer, "JWT_BLACKLIST_DEFAULT_EXPIRY_HOURS", 1}


# --------------------------------------
# Transports, Channels, etc
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

config :gateway, Gateway.Transports.ServerSentEvents,
  user_channel_name_mf: {GatewayWeb.Presence.Channel, :user_channel_name},
  role_channel_name_mf: {GatewayWeb.Presence.Channel, :role_channel_name}

config :gateway, GatewayWeb.Presence.Channel,
  # See "JWT payload fields"
  jwt_user_field: jwt_payload_field_map.user,
  # See "JWT payload fields"
  jwt_roles_field: jwt_payload_field_map.roles,
  # See "User Roles"
  privileged_roles: privileged_roles

config :gateway, GatewayWeb.Presence.Controller,
  # See "User Roles"
  session_role: session_role



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
