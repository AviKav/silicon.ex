import Config

case System.get_env("NIF_LOAD_PATH") do
  nif_path when not is_nil(nif_path) and is_bitstring(nif_path) ->
    config :silicon, Silicon.Native,
      load_from: {:silicon, nif_path},
      skip_compilation?: true

  nil -> true # Keep default Rustler behaviour
end


env_conf = "#{config_env()}.exs"
if File.exists?(env_conf), do: import_config(env_conf)
