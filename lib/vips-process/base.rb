require 'vips-process'

module Vips
  module Process
    class Base
      include Vips::Process

      attr_accessor :src, :dst

      def initialize(src, dst=nil)
        @src = src
        @dst = dst || src
      end
    end
  end
end
