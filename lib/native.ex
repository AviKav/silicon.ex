defmodule Elixir.Silicon.Native do
  use Rustler, otp_app: :silicon, crate: "silicon_nif"
  use TypeCheck

  @moduledoc """
  Don't use the functions prefixed with `nif_`. The error messages for input validation are bad to misleading.
  """
  @type! rustler_error :: any()

  @spec! format_png(String.t(), Silicon.Options.Format.t()) :: binary() | rustler_error()
  def format_png(code, options), do: nif_format_png(code, options)
  def nif_format_png(_code, _options), do: :erlang.nif_error(:nif_not_loaded)

  @spec! format_rgba8(String.t(), Silicon.Options.Format.t()) :: binary() | rustler_error()
  def format_rgba8(code, options), do: nif_format_rgba8(code, options)
  def nif_format_rgba8(_code, _options), do: :erlang.nif_error(:nif_not_loaded)

  @spec! load_theme() :: Silicon.Options.Format.theme_resource() | rustler_error()
  def load_theme(resource_binary), do: nif_load_theme(resource_binary)
  def nif_load_theme(_resource_binary), do: :erlang.nif_error(:nif_not_loaded)
end
