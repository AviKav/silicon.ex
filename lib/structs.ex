#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.
defmodule Silicon.FormatOptions do
  @type t :: %__MODULE__{
          lang: String.t(),
          theme: String.t(),
          image_options: Silicon.ImageOptions.t() | nil
        }

  defstruct [:lang, :theme, :image_options]
end

defmodule Silicon.ImageOptions do
  @type u32 :: 0..0xFFFFFFFF
  @type i32 :: -0x80000000..0x7FFFFFFF
  @type t :: %__MODULE__{
          # Pad between lines
          line_pad: u32() | nil,
          # Show line number
          line_number: boolean() | nil,
          # Font of english character, should be mono space font
          # Silicon docs say it will use Hack font (size: 26.0) by default
          font: [{String.t(), number()}] | nil,
          # Highlight lines
          highlight_lines: [u32()] | nil,
          # Whether show the window controls
          window_controls: boolean() | nil,
          # Window title
          window_title: String.t() | nil,
          # Whether round the corner of the image
          round_corner: boolean() | nil,
          # Shadow adder,
          shadow_adder: Silicon.ShadowOptions.t() | nil,
          # Tab width
          tab_width: 0..255 | nil,
          # Line Offset
          line_offset: u32() | nil
        }

  defstruct [
    :line_pad,
    :line_number,
    :font,
    :highlight_lines,
    :window_controls,
    :window_title,
    :round_corner,
    :shadow_adder,
    :tab_width,
    :line_offset
  ]
end

defmodule Silicon.ShadowOptions do
  @type u32 :: 0..0xFFFFFFFF
  @type i32 :: -0x80000000..0x7FFFFFFF
  # TODO: Support images for the background
  @type background :: {:solid, Silicon.RGBA.t()}

  @type t :: %__MODULE__{
          background: background(),
          shadow_color: Silicon.RGBA.t(),
          blur_radius: float() | nil,
          pad_horiz: u32() | nil,
          pad_vert: u32() | nil,
          offset_x: i32() | nil,
          offset_y: i32() | nil
        }

  defstruct [
    :background,
    :shadow_color,
    :blur_radius,
    :pad_horiz,
    :pad_vert,
    :offset_x,
    :offset_y
  ]
end

# Should this be a tuple?
defmodule Silicon.RGBA do
  @type u8 :: 0..255
  @type t :: %__MODULE__{
          r: u8(),
          g: u8(),
          b: u8(),
          a: u8()
        }
  defstruct [:r, :g, :b, a: 255]
end
