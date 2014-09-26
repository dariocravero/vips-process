require 'vips-process/base'
require 'vips-process/gaussian-blur'
require 'vips-process/resize'
require 'vips-process/strip'

class MyImage < Vips::Process::Base
  include Vips::Process::GaussianBlur
  include Vips::Process::Resize
  include Vips::Process::Strip

  version(:thumb)   { resize_to_fit 150, 150 }
  version(:blurred) { gaussian_blur 10 }
  version :blurred_thumb, [:thumb, :blurred]
  version(:blurred_thumb_stripped, [:blurred_thumb]) { strip }
end

MyImage.new('/path/to/src.jpg')
  .thumb_version('/path/to/thumb.jpg')
  .blurred('/path/to/blurred.jpg')
  .blurred_thumb('/path/to/blurred_thumb.jpg')
  .blurred_thumb_stripped('/path/to/blurred_thumb_stripped.jpg')
