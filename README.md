# Vips::Process

Process your images with ruby-vips using an operation-oriented approach.

Inspired by [carrierwave-vips](https://github.com/eltiare/carrierwave-vips/blob/master/lib/carrierwave/vips.rb)
and [@jcupitt's](https://github.com/jcupitt/ruby-vips/issues/60#issuecomment-56934898) gaussian blur example.

Made with <3 @[UXtemple](http://uxtemple.com). :)

[Vips](http://www.vips.ecs.soton.ac.uk/index.php?title=VIPS) is an open source and super fast image
processing library with a very low memory footprint.
You can use it as a replacement to `ImageMagick`, `MiniMagick` and the likes.
See the benchmarks [here](http://www.vips.ecs.soton.ac.uk/index.php?title=Speed_and_Memory_Use).

## Installation

This gem requires `libvips` in order to run. For instructions on how to get it in OS X and Linux, follow [these installation guides](https://github.com/jcupitt/ruby-vips#installation-prerequisites).

Add this line to your application's Gemfile:

```ruby
gem 'vips-process'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vips-process

## Usage

Define your image class and explicity include the processes you want to apply to it:

```
# example.rb
require 'vips-process'
require 'vips-process/gaussian-blur'
require 'vips-process/resize'

class MyImage
  include Vips::Process
  include Vips::Process::GaussianBlur
  include Vips::Process::Resize
  include Vips::Process::Quality

  attr_accessor :src, :dst

  def initialize(src, dst=nil)
    @src = src
    @dst = dst || src
  end

  version(:blurred)        { gaussian_blur }
  version(:thumb)          { resize_to_fit 150, 150 }
  version :blurred_thumb, [:thumb, :blurred]
  version(:blurred_thumb, [:thumb, :blurred]) { quality 50 }
end
```

`Vips::Process` also comes with a `Base` helper class that takes care of defining `src`, `dst` and
including `Vips::Process` for you. It's the recommended way to go about it and you can use it as follows

```
require 'vips-process/base'
require 'vips-process/gaussian-blur'

class MyImage < Vips::Process::Base
  include Vips::Process::GaussianBlur

  version(:blurred) { gaussian_blur }
end
```

### Working with versions

Version dependencies are recursive. I.e., if you have:

```
class MyImage < Vips::Process::Base
  # ...

  version(:a) { ... }
  version(:b, [:a])
  version(:c, [:b])

  # ...
end
```
Calling `image.c_version` will actually call `image.b_version` which will in turn call
`image.a_version` and then run version `b`'s code.


`MyImage.versions` will return an array with the list of versions your image supports.


Calling `image.versions!` will process all versions at once and will return an array with tuples
like `[version_name, output_path]`. E.g. with the image class above:

```
image = MyImage.new('/path/to/src.jpg')
image.versions! #=> [[:a, '/path/to/src-a.jpg'], [:b, '/path/to/src-b.jpg'], [:c, '/path/to/src-c.jpg']]
```

`versions!` takes one optional argument: the `base` destination. This could be either a directory
or a filename.

If you use a directory, all new files will be written to that directory
(which will be created recursively if it doesn't exist) with the version's name followed by the `src`
file extension. E.g.:
```
image = MyImage.new('/path/to/src.jpg')
image.versions!('/path/to/dir/') #=> [[:a, '/path/to/dir/a.jpg'], [:b, '/path/to/dir/b.jpg'], [:c, '/path/to/dir/c.jpg']]
```

If you use a filename, all new files will be written next to that file prepending the version's name
and using its extension. E.g.:

```
image = MyImage.new('/path/to/src.jpg')
image.versions!('/path/to/dst.jpeg') #=> [[:a, '/path/to/dst-a.jpeg'], [:b, '/path/to/dest-b.jpeg'], [:c, '/path/to/dest-c.jpg']]
```

By default we use the `src`'s filename.

## Supported processes

All examples live in the [/examples](https://github.com/dariocravero/vips-process/tree/master/examples)
folder of this repo.

### AutoOrient

Read the camera EXIF data to determine orientation and adjust accordingly 

Usage:

Include it in your image class `include Vips::Process::AutoOrient` and
call it `MyImage.new('/path/to/src').auto_orient`.

### GaussianBlur

Applies a gaussian blur to an image.

Usage:

Include it in your image class `include Vips::Process::GaussianBlur` and
call it `MyImage.new('/path/to/src').gaussian_blur(5, 0.2)`.

The first argument is the `radius` and the second one is the `minimium amplitude` we consider,
which sets how far out the mask goes; it's optional and defaults to `0.2`.

### Convert

Converts an image to a different format.

Usage:

Include it in your image class `include Vips::Process::Convert` and
call it `MyImage.new('/path/to/src.jpg').convert(:png)`.

The first argument is the `format` we'll conver the file to (jpeg or png) and
the second one is an optional hash of `options` to be passed to the converting function
(ie, :interlace => true for png).

### Crop

Crop an image in the desired dimentions.

Usage:

Include it in your image class `include Vips::Process::Crop` and
call it `MyImage.new('/path/to/src.jpg').crop(height: 100, top: 0.5)`.

Because it's arguments can be used in so many different ways I've decided to make them keyword
arguments with a default that would give you the same image back.

There are four possible arguments in total: `width`, `height`, `left` and `top`.

`width` and `height` do just that: they crop the resulting image in size.

`left` and `top` are slightly different as they operate in two modes: if you use an Integer it's
the just the offset. However, if a Float between 0 and 1 is passed it's used to position the cropping
mask accordingly to the `width` and or `height` respectively. This is probable best seen with an
example:

```
 Given:

  i=image        cm=crop mask
 ________        ________
 |      |        |      |
 |      |        |      |
 |      |        --------
 |      |
 |      |
 ________


 crop height: cm.height, top: 0.0 will result in:

 ________
 | final|
 | img  |
 --------
 |      |
 |  x   |
 ________

 crop height: cm.height, top: 0.5 will result in:

 ________
 |  x   |
 --------
 | final|
 | img  |
 --------
 |  x   |
 ________

 crop height: cm.height, top: 1.0 will result in:
 ________
 |      |
 |  x   |
 --------
 | final|
 | img  |
 ________
```

It's also very powerful when used together with resize.
E.g.: say you have an image that is 3000x2000 px.
`image.resize_to_width(300).crop(height: 150, top: 0.5).process!` will first resize it to
300x200 px and then it will crop it using a 150 height mask positioned in the middle of the
resized image. It will give you an image of full width but with height starting at 25px and
finishing at 175px. Here's a graphical example:

If the cropping area is outside of the boundaries of the current image `crop` will throw an
Exception. If you would like it to silently ignore that issue and return the image as it came
use `crop!` instead.

### Quality

Changes quality of the image (if supported by the file format)

Usage:

Include it in your image class `include Vips::Process::Quality` and
call it `MyImage.new('/path/to/src.jpg').quality(50)`.

It takes the `quality` as an argument which defaults to `75`. This value should be between 0 and 100.
Currently `jpegs` are only supported. Using any other image formats will be a no-op.

### Resize

There are three resize methods. Each of them will sharpen the image after doing its work.

Usage:

Include it in your image class `include Vips::Process::Resize`.
All of them take the same arguments: `width` and `height`.

#### resize_to_fit

Resize the image to fit within the specified dimensions while retaining
the original aspect ratio. The image may be shorter or narrower than
specified in the smaller dimension but will not be larger than the
specified values.

Call it as follows: `MyImage.new('/path/to/src.jpg').resize_to_fit(150, 150)`

#### resize_to_fill

Resize the image to fit within the specified dimensions while retaining
the aspect ratio of the original image. If necessary, crop the image in
the larger dimension.

Call it as follows: `MyImage.new('/path/to/src.jpg').resize_to_fill(150, 150)`

#### resize_to_limit

Resize the image to fit within the specified dimensions while retaining
the original aspect ratio. Will only resize the image if it is larger than the
specified dimensions. The resulting image may be shorter or narrower than specified
in the smaller dimension but will not be larger than the specified values.

Call it as follows: `MyImage.new('/path/to/src.jpg').resize_to_limit(150, 150)`

### Strip

Remove all exif and icc data when writing to a file. This method does
not actually remove any metadata but rather marks it to be removed when
writing the file.

Usage:

Include it in your image class `include Vips::Process::Strip` and
call it `MyImage.new('/path/to/src.jpg').strip`.

## Version definition

You can also define versions and compose them as you wish.

A version is defined by calling `version` in your image class.

A version can have dependencies which will be executed sequentially. Of course composed versions
can also take a block and do more things. Maybe this can grow into a set of common versions?

## TODO

1. Increment test coverage.
2. Implement version caching.
3. Implement more processes. Feel free to add what you may need.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/vips-process/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
