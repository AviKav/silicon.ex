defmodule Elixir.Silicon.Native do
  alias Silicon.FormatOptions
  use Rustler, otp_app: :silicon, crate: "silicon_nif"

  @spec nif_format(String.t(), FormatOptions.t()) :: binary()
  def nif_format(_code, _options), do: :erlang.nif_error(:nif_not_loaded)
end
