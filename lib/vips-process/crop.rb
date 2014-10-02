module Vips
  module Process
    module Crop
      ##
      # Crop an image in the desired dimentions.
      #
      # Pretty much all arguments are optional making it very flexible for you to create all
      # sort of croppings.
      #
      # @param  left    Number    if it's a Float between 0 and 1 it will use that to create a band
      #                           in which it will displace the width of it.
      #                           if it's an Integer it's the offset from the left.
      # @param  top     Number    if it's a Float between 0 and 1 it will use that to create a band
      #                           in which it will displace the height of it.
      #                           if it's an Integer it's the offset from the top.
      # @param  width   Integer   the width to crop to
      # @param  height  Integer   the height to crop to
      #
      # It's very powerful when used with resize. E.g.: say you have an image that is 3000x2000 px.
      # `image.resize_to_width(300).crop(height: 150, top: 0.5).process!` will first resize it to
      # 300x200 px and then it will crop it using a 150 height mask positioned in the middle of the
      # resized image. It will give you an image of full width but with height starting at 25px and
      # finishing at 175px. Here's a graphical example:
      #
      # Given:
      #
      #  i=image        cm=crop mask
      # ________        ________
      # |      |        |      |
      # |      |        |      |
      # |      |        --------
      # |      |
      # |      |
      # ________
      #
      #
      # crop height: cm.height, top: 0.0 will result in:
      #
      # ________
      # | final|
      # | img  |
      # --------
      # |      |
      # |  x   |
      # ________
      #
      # crop height: cm.height, top: 0.5 will result in:
      #
      # ________
      # |  x   |
      # --------
      # | final|
      # | img  |
      # --------
      # |  x   |
      # ________
      #
      # crop height: cm.height, top: 1.0 will result in:
      # ________
      # |      |
      # |  x   |
      # --------
      # | final|
      # | img  |
      # ________
      #
      def crop(left: 0, top: 0, width: nil, height: nil)
        manipulate! do |image|
          width   ||= image.x_size
          height  ||= image.y_size
          top       = top.is_a?(Float)  && top.between?(0,1)  ? (image.y_size - height) * top : top
          left      = left.is_a?(Float) && left.between?(0,1) ? (image.x_size - width) * left : left

          image.extract_area left, top, width, height
        end
        self
      end
    end # Crop
  end # Process
end # Vips
