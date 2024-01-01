defmodule Elixir.Silicon.Native do
  alias Silicon.FormatOptions
  use Rustler, otp_app: :silicon, crate: "silicon_nif"

  @spec nif_format_png(String.t(), FormatOptions.t()) :: binary()
  def nif_format_png(_code, _options), do: :erlang.nif_error(:nif_not_loaded)

  @spec nif_format_rgba8(String.t(), FormatOptions.t()) :: binary()
  def nif_format_rgba8(_code, _options), do: :erlang.nif_error(:nif_not_loaded)
end
