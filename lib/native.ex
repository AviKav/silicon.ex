defmodule Elixir.Silicon.Native do
  use Rustler, otp_app: :silicon, crate: "silicon_nif"
  use TypeCheck

  @spec! format_png(String.t(), Silicon.Options.Format.t()) :: binary()
  def format_png(code, options), do: nif_format_png(code, options)

  @spec nif_format_png(String.t(), Silicon.Options.Format.t()) :: binary()
  def nif_format_png(_code, _options), do: :erlang.nif_error(:nif_not_loaded)

  @spec! format_rgba8(String.t(), Silicon.Options.Format.t()) :: binary()
  def format_rgba8(code, options), do: nif_format_rgba8(code, options)

  @spec nif_format_rgba8(String.t(), Silicon.Options.Format.t()) :: binary()
  def nif_format_rgba8(_code, _options), do: :erlang.nif_error(:nif_not_loaded)
end
