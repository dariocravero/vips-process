require 'vips-process/base'
require 'vips-process/crop'

class MyImage < Vips::Process::Base
  include Vips::Process::Crop
end

MyImage.new('/path/to/src.jpg').crop(height: 100, top: 0.5).process!
