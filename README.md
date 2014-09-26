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
