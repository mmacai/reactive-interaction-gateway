# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"Yj=0.X~GBEXX5s7d.f0.vNT</aAPot4w2YtXz0krdC<BsLmLe7Xama}=.^{R**|G"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set vm_args: "rel/vm.args"
  set cookie: :"a8tG3Xr[5d)Rk@}OMKGahA.bOZEe{c&7fPcj@(]yE0iv0e?jEsf5EcJGy{m`nS>~"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :gateway do
  set version: current_version(:gateway)
  set applications: [
    :runtime_tools
  ]
end

