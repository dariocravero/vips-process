module Vips
  module Process
    module Quality
      ##
      # Changes quality of the image (if supported by the file format)
      #
      # @param  percent   Integer   quality from 0 to 100
      def quality(percent=75)
        manipulate! do |image|
          @_format_opts = { quality: percent } if jpeg? || @_format == JPEG
          image
        end
        self
      end
    end # Quality
  end # Process
end # Vips
