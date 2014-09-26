require 'vips-process/base'
require 'vips-process/strip'

class MyImage < Vips::Process::Base
  include Vips::Process::Strip
end

MyImage.new('/path/to/src.jpg').strip.process!
