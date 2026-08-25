# Imlib2

Nim bindings for [Imlib2](https://www.enlightenment.org/about-imlib), a native
image loading, transformation, compositing, and rendering library. Thanks to
Vindaar for his [initial gist](https://gist.github.com/Vindaar/e518e310eb3a0a95bdda7bbe8e4341f8).

## Requirements

- Nim 1.2.6 or newer
- Imlib2 1.12.6 development files discoverable through `pkg-config`
- the Nim `x11` package, installed automatically from the package manifest

Imlib2 may be built without X11 for headless image processing. Display and
drawable APIs are omitted when compiling with `-d:X_DISPLAY_MISSING`.

## Quick start

This example creates and fills a small image entirely in memory:

```nim
import imlib2

let image = imlib_create_image(64, 48)
doAssert image != nil

imlib_context_set_image(image)
defer: imlib_free_image()

imlib_context_set_color(40, 90, 180, 255)
imlib_image_fill_rectangle(0, 0, 64, 48)
doAssert imlib_image_get_width() == 64
doAssert imlib_image_get_height() == 48
```

Imlib2 uses a current context. Functions such as `imlib_image_get_width()` and
`imlib_free_image()` operate on the image selected with
`imlib_context_set_image()`. Image handles returned by creation and loading
functions must be selected and freed when no longer needed. Memory returned by
`imlib_image_get_data()` remains owned by the image and must be returned with
`imlib_image_put_back_data()`.

Loading functions return `nil` on failure. The `*_with_errno_return` loading
and saving variants set an explicit error code. `imlib_get_error()` returns the
most recent loader/saver error, and `imlib_strerror()` converts that code to
library-owned text which must not be modified or freed. Callbacks are C
callbacks: they must not raise exceptions across the C boundary, and any
captured state must outlive its registration.

## Compatibility

The bindings track the Imlib2 1.12.6 public API. The headless allocation,
context, dimension, callback registration, version, and cleanup tests run on
Linux x86-64 with Nim 2.2.10 and Imlib2 1.12.6.

Run the test with:

```sh
nimble test
```

## Example font

The interactive example includes an unmodified copy of Abel Regular from
[Google Fonts](https://github.com/google/fonts/tree/main/ofl/abel). The font is
distributed under the SIL Open Font License 1.1, separately from the MIT
license declared for this Nim package. Its copyright, exact source revision,
checksum, and license text are recorded in
[`examples/ttfonts`](examples/ttfonts/README.md).
