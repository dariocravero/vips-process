require 'vips-process/base'
require 'vips-process/resize'

class MyImage < Vips::Process::Base
  include Vips::Process::Resize
end

MyImage.new('/path/to/src').resize_to_fit(150, 150).process!

MyImage.new('/path/to/src2').resize_to_fill(150, 150).process!

MyImage.new('/path/to/src3').resize_to_limit(150, 150).process!
