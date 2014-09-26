require 'vips-process/base'
require 'vips-process/convert'

class MyImage < Vips::Process::Base
  include Vips::Process::Convert
end

MyImage.new('/path/to/src.jpg').convert(:png).process!
