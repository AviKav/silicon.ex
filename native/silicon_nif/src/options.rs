//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

use rustler::{NifStruct, NifTaggedEnum, ResourceArc};

use silicon::formatter::ImageFormatterBuilder;
use silicon::utils::ShadowAdder;

use crate::{ThemeEnum, ThemeSetResource};

#[derive(Debug, NifStruct)]
#[module = "Silicon.RGBA"]
pub(crate) struct Rgba {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
}

impl From<Rgba> for image::Rgba<u8> {
    fn from(val: Rgba) -> Self {
        let Rgba { r, g, b, a } = val;
        image::Rgba::<u8>([r, g, b, a])
    }
}

#[derive(Debug, NifTaggedEnum)]
pub(crate) enum Background {
    Solid(Rgba),
    // Image(RgbaImage), // TODO
}

#[derive(Debug, NifStruct)]
#[module = "Silicon.Options.Shadow"]
pub(crate) struct ShadowOptions {
    pub background: Option<Background>,
    pub shadow_color: Option<Rgba>,
    pub blur_radius: Option<f32>,
    pub pad_horiz: Option<u32>,
    pub pad_vert: Option<u32>,
    pub offset_x: Option<i32>,
    pub offset_y: Option<i32>,
}

#[derive(Debug, NifStruct)]
#[module = "Silicon.Options.Image"]
pub(crate) struct ImageOptions {
    /// Pad between lines
    pub line_pad: Option<u32>,
    /// Show line number
    pub line_number: Option<bool>,
    /// Font of english character, should be mono space font
    /// Silicon docs say it will use Hack font (size: 26.0) by default
    pub font: Option<Vec<(String, f32)>>,
    /// Highlight lines
    pub highlight_lines: Option<Vec<u32>>,
    /// Whether show the window controls
    pub window_controls: Option<bool>,
    /// Window title
    pub window_title: Option<String>,
    /// Whether round the corner of the image
    pub round_corner: Option<bool>,
    /// Shadow adder,
    pub shadow_adder: Option<ShadowOptions>,
    /// Tab width
    pub tab_width: Option<u8>,
    /// Line Offset
    pub line_offset: Option<u32>,
}

#[derive(NifStruct)]
#[module = "Silicon.Options.Format"]
pub(crate) struct FormatOptions {
    pub lang: String,
    pub theme: ThemeEnum,
    pub theme_set: Option<ResourceArc<ThemeSetResource>>,
    pub image_options: Option<ImageOptions>,
}

pub(crate) fn do_image(opts: ImageOptions) -> ImageFormatterBuilder<String> {
    let Wrapper(format_builder) = Wrapper(ImageFormatterBuilder::<String>::new())
        .apply(opts.line_pad, ImageFormatterBuilder::line_pad)
        .apply(opts.line_number, ImageFormatterBuilder::line_number)
        .apply(opts.font, ImageFormatterBuilder::font)
        .apply(opts.highlight_lines, ImageFormatterBuilder::highlight_lines)
        .apply(opts.window_controls, ImageFormatterBuilder::window_controls)
        .flat_apply(opts.window_title, ImageFormatterBuilder::window_title)
        .apply(opts.round_corner, ImageFormatterBuilder::round_corner)
        .apply(opts.tab_width, ImageFormatterBuilder::tab_width)
        .apply(opts.line_offset, ImageFormatterBuilder::line_offset)
        .apply(opts.shadow_adder, do_shadow);
    format_builder
}
pub(crate) fn do_shadow<T: AsRef<str> + Default>(
    format_builder: ImageFormatterBuilder<T>,
    opts: ShadowOptions,
) -> ImageFormatterBuilder<T> {
    let Wrapper(shadow_builder) = Wrapper(ShadowAdder::default())
        .apply(opts.blur_radius, ShadowAdder::blur_radius)
        .apply(opts.pad_horiz, ShadowAdder::pad_horiz)
        .apply(opts.pad_vert, ShadowAdder::pad_vert)
        .apply(opts.offset_x, ShadowAdder::offset_x)
        .apply(opts.offset_y, ShadowAdder::offset_y)
        .apply(opts.shadow_color, |shadow_builder, value| {
            shadow_builder.shadow_color(value.into())
        })
        .apply(opts.background, |shadow_builder, background| {
            let bg = match background {
                Background::Solid(rgba) => silicon::utils::Background::Solid(rgba.into()),
            };
            shadow_builder.background(bg)
        });

    format_builder.shadow_adder(shadow_builder)
}
pub(crate) struct Wrapper<T>(T);

impl<T> Wrapper<T> {
    pub fn apply<U>(self, value: Option<U>, f: impl FnOnce(T, U) -> T) -> Self {
        if let Some(value) = value {
            Wrapper(f(self.0, value))
        } else {
            self
        }
    }

    pub fn flat_apply<U>(self, value: Option<U>, f: impl FnOnce(T, Option<U>) -> T) -> Self {
        self.apply(value, |obj, value| f(obj, Some(value)))
    }
}
