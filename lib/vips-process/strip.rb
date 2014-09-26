module Vips
  module Process
    module Strip
      ##
      # Remove all exif and icc data when writing to a file. This method does
      # not actually remove any metadata but rather marks it to be removed when
      # writing the file.
      #
      def strip
        manipulate! do |image|
          @_on_process << ->(writer) do
            writer.remove_exif
            writer.remove_icc
          end

          image
        end
        self
      end
    end # Strip
  end # Process
end # Vips
