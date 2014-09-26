require 'vips-process/base'
require 'vips-process/gaussian-blur'
require 'vips-process/resize'

class MyImage < Vips::Process::Base
  include Vips::Process::GaussianBlur
  include Vips::Process::Resize

  version(:blurred)        { gaussian_blur }
  version(:thumb)          { resize_to_fit 150, 150 }
  version :blurred_thumb, [:thumb, :blurred]
  version(:blurred_thumb, [:thumb, :blurred]) { quality 50 }
end
