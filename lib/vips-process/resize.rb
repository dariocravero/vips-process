module Vips
  module Process
    module Resize
      SHARPEN_MASK = begin
        conv_mask = [
          [ -1, -1, -1 ],
          [ -1, 24, -1 ],
          [ -1, -1, -1 ]
        ]
        ::VIPS::Mask.new conv_mask, 16
      end

      ##
      # Resize the image to fit within the specified dimensions while retaining
      # the original aspect ratio. The image may be shorter or narrower than
      # specified in the smaller dimension but will not be larger than the
      # specified values.
      #
      # @param  width   Integer   the width to scale the image to
      # @param  height  Integer   the height to scale the image to
      def resize_to_fit(width, height)
        manipulate! do |image|
          resize_image image, width, height
        end
        self
      end

      ##
      # Resize the image to fit within the specified dimensions while retaining
      # the aspect ratio of the original image. If necessary, crop the image in
      # the larger dimension.
      #
      # @param  width   Integer   the width to scale the image to
      # @param  height  Integer   the height to scale the image to
      def resize_to_fill(width, height)
        manipulate! do |image|
          image = resize_image image, width, height, :max
          top   = 0
          left  = 0

          if image.x_size > width
            left = (image.x_size - width) / 2
          elsif image.y_size > height
            top = (image.y_size - height) / 2
          end

          image.extract_area left, top, width, height
        end
        self
      end

      ##
      # Resize the image to fit within the specified dimensions while retaining
      # the original aspect ratio. Will only resize the image if it is larger than the
      # specified dimensions. The resulting image may be shorter or narrower than specified
      # in the smaller dimension but will not be larger than the specified values.
      #
      # @param  width   Integer   the width to scale the image to
      # @parma  height  Integer   the height to scale the image to
      def resize_to_limit(width, height)
        manipulate! do |image|
          image = resize_image(image, width, height) if width < image.x_size || height < image.y_size
          image
        end
        self
      end

      private def resize_image(image, width, height, min_or_max = :min)
        ratio = get_ratio image, width, height, min_or_max
        return image if ratio == 1
        if ratio > 1
          image = image.affinei_resize :nearest, ratio
        else
          if ratio <= 0.5
            factor = (1.0 / ratio).floor
            image = image.shrink factor
            image = image.tile_cache image.x_size, 1, 30
            ratio = get_ratio image, width, height, min_or_max
          end
          image = image.affinei_resize :bicubic, ratio
          image = image.conv SHARPEN_MASK
        end
        image
      end

      private def get_ratio(image, width,height, min_or_max = :min)
        width_ratio = width.to_f / image.x_size
        height_ratio = height.to_f / image.y_size
        [width_ratio, height_ratio].send min_or_max
      end
    end # Resize
  end # Process
end # Vips
