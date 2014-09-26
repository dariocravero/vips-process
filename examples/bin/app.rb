#!/usr/bin/env ruby

require 'clap'
require 'vips-process/base'
require 'vips-process/gaussian-blur'
require 'vips-process/resize'

class MyImage < Vips::Process::Base
  include Vips::Process::GaussianBlur
  include Vips::Process::Resize

  version(:thumb)   { resize_to_fit 150, 150 }
  version(:blurred) { gaussian_blur 10 }
end

def prefix(src, with)
  "#{src.sub(/(\.[[:alnum:]]+)$/i, "#{with}\1")}#{File.extname(src)}"
end

Clap.run ARGV,
  '-t' => ->(src) { MyImage.new(src, prefix(src, '.thumb')).thumb_version },
  '-b' => ->(src) { MyImage.new(src, prefix(src, '.blurred')).blurred_version }
