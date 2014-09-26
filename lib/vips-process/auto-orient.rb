module Vips
  module Process
    module AutoOrient
      EMPTY_STRING          = ''.freeze
      EXIF_ORIENTATION      = 'exif-Orientation'.freeze
      EXIF_IFD0_ORIENTATION = 'exif-ifd0-Orientation'.freeze

      # Read the camera EXIF data to determine orientation and adjust accordingly
      def auto_orient
        manipulate! do |image|
          o   = image.get(EXIF_ORIENTATION).to_i      rescue nil
          o ||= image.get(EXIF_IFD0_ORIENTATION).to_i rescue 1

          case o
          when 1
            # Do nothing, everything is peachy
          when 6
            image.rot270
          when 8
            image.rot180
          when 3
            image.rot90
          else
            raise('Invalid value for Orientation: ' + o.to_s)
          end
          image.set EXIF_ORIENTATION, EMPTY_STRING
          image.set EXIF_IFD0_ORIENTATION, EMPTY_STRING
        end
        self
      end
    end # AutoOrient
  end # Process
end # Vips
