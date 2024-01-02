//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

use image::{DynamicImage, EncodableLayout};
use rustler::{lazy_static, Binary, Env, NewBinary, NifResult, NifUntaggedEnum, ResourceArc, Term};
use std::error::Error;
use std::io::Cursor;

use syntect::highlighting::{Theme, ThemeSet};

use silicon::assets::HighlightingAssets;
use silicon::formatter::ImageFormatterBuilder;
use syntect::easy::HighlightLines;
use syntect::util::LinesWithEndings;

use crate::options::FormatOptions;

mod options;

lazy_static::lazy_static! {
    static ref HIGHLIGHTING_ASSETS: HighlightingAssets = HighlightingAssets::new();
}

fn format(
    _env: Env<'_>,
    code: String,
    options: options::FormatOptions,
) -> Result<DynamicImage, Box<dyn Error>> {
    let theme = match options.theme {
        ThemeEnum::Name(name) => HIGHLIGHTING_ASSETS
            .theme_set
            .themes
            .get(name.as_str())
            .ok_or::<Box<dyn Error>>("Unknown theme".into())?,
        ThemeEnum::Resource(ref resource) => &resource.themes,
    };

    let syntax = HIGHLIGHTING_ASSETS
        .syntax_set
        .find_syntax_by_token(options.lang.as_str())
        .ok_or::<Box<dyn Error>>("Unknown lang".into())?;

    let mut h = HighlightLines::new(syntax, theme);
    let highlight = LinesWithEndings::from(code.as_str())
        .map(|line| h.highlight_line(line, &HIGHLIGHTING_ASSETS.syntax_set))
        .collect::<Result<Vec<_>, _>>()?;

    let image_builder = match options.image_options {
        Some(i_options) => options::do_image(i_options),
        None => ImageFormatterBuilder::new(),
    };

    let mut formatter = image_builder.build()?;

    let image = formatter.format(&highlight, &theme);

    Ok(image)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_load_theme(theme_data: Binary) -> NifResult<ResourceArc<ThemeSetResource>> {
    let theme_set = ThemeSet::load_from_reader(&mut Cursor::new(theme_data.as_bytes()))
        .map_err(to_rustler_error)?;
    Ok(ResourceArc::new(ThemeSetResource { themes: theme_set }))
}

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_format_png(env: Env<'_>, code: String, options: FormatOptions) -> NifResult<Binary<'_>> {
    let mut bytes: Vec<u8> = Vec::new();

    format(env, code, options)
        .and_then(|image| {
            image.write_to(&mut Cursor::new(&mut bytes), image::ImageOutputFormat::Png)?;
            let mut out_binary = NewBinary::new(env, bytes.len());
            out_binary.as_mut_slice().copy_from_slice(bytes.as_bytes());

            Ok(out_binary.into())
        })
        .map_err(to_rustler_error)
}

#[rustler::nif(schedule = "DirtyCpu")]
fn nif_format_rgba8(env: Env<'_>, code: String, options: FormatOptions) -> NifResult<Binary<'_>> {
    format(env, code, options)
        .and_then(|image| {
            let rgba8 = image
                .as_rgba8()
                .ok_or::<Box<dyn Error>>("Underlying library returned non-rgba image".into())?;
            let image_slice = rgba8.as_bytes();
            let mut out_binary = NewBinary::new(env, image_slice.len());
            out_binary.as_mut_slice().copy_from_slice(image_slice);
            Ok(Binary::from(out_binary))
        })
        .map_err(to_rustler_error)
}

fn to_rustler_error(err: impl Into<Box<dyn Error>>) -> rustler::Error {
    rustler::Error::Term(Box::new(err.into().to_string()))
}

#[derive(NifUntaggedEnum)]
pub(crate) enum ThemeEnum {
    Name(String),
    Resource(ResourceArc<ThemeSetResource>),
}

pub(crate) struct ThemeSetResource {
    themes: Theme,
}

fn load(env: Env, _: Term) -> bool {
    rustler::resource!(ThemeSetResource, env);
    true
}

rustler::init!(
    "Elixir.Silicon.Native",
    [nif_format_png, nif_format_rgba8],
    load = load
);
