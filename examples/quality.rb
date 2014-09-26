require 'vips-process/base'
require 'vips-process/quality'

class MyImage < Vips::Process::Base
  include Vips::Process::Quality
end

MyImage.new('/path/to/src.jpg').quality(50).process!
