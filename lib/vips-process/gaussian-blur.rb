module Vips
  module Process
    module GaussianBlur
      ##
      # We normalise to 20 so that the mask sum stays under 255 for most blurs.
      # This will let Vips use its fast SSE path for 8-bit images
      NORMALISE_TO = 20.0

      # The size of the biggest mask we support
      BIGGEST_MASK = 10000

      ##
      # Apply gaussian blur to an image.
      #
      # @param  sigma      Float    roughly the radius
      # @param  min_ampl   Float    minimium amplitude we consider, it sets how far out the mask goes
      def gaussian_blur(sigma, min_ampl=0.2)
        manipulate! do |image|
          image.convsep gaussian_mask(sigma, min_ampl)
        end
        self
      end

      # Make a 1D int gaussian mask suitable for a separable convolution
      private def gaussian_mask(sigma, min_ampl)
        sigma2 = 2.0 * sigma ** 2.0

        # Find the size of the mask
        max_size = (1..BIGGEST_MASK).detect { |x| Math::exp(-x ** 2.0 / sigma2) < min_ampl }
        throw :mask_too_large unless max_size

        width = max_size * 2 + 1
        mask = (0...width).map do |x|
          d = (x - width / 2) ** 2
          (NORMALISE_TO * Math::exp(-d / sigma2)).round
        end
        sum = mask.reduce(:+)

        VIPS::Mask.new [mask], sum, 0
      end
    end # GaussianBlur
  end # Process
end # Vips
