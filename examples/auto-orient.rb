require 'vips-process/base'
require 'vips-process/auto-orient'

class MyImage < Vips::Process::Base
  include Vips::Process::AutoOrient
end

MyImage.new('/path/to/src.jpg').auto_orient.process!
