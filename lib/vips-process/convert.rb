module Vips
  module Process
    module Convert
      ALLOWED_FORMATS = [JPEG, PNG]

      ##
      # Converts an image to a different format
      #
      # @param  format  String  the format we'll convert the file to (jpeg, png)
      # @param  opts    Hash    options to be passed to converting function (ie, :interlace => true for png)
      #
      def convert(format, opts = {})
        format = format.to_s.downcase
        raise ArgumentError, "Format must be one of: #{ALLOWED_FORMATS.join(',')}" unless ALLOWED_FORMATS.include?(format)
        @_format = format
        @_format_opts = opts
        self
      end
    end # Convert
  end # Process
end # Vips
