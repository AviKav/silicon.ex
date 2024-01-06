import Config

if nif_path = System.get_env("NIF_LOAD_PATH") do
  config :silicon, Silicon.Native,
    load_from: {:silicon, nif_path},
    skip_compilation?: true
end

env_conf = "#{config_env()}.exs"
if File.exists?(env_conf), do: import_config(env_conf)
