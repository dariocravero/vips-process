require 'vips-process/base'
require 'vips-process/gaussian-blur'

class MyImage < Vips::Process::Base
  include Vips::Process::GaussianBlur
end

MyImage.new('/path/to/src.jpg').gaussian_blur.process!
