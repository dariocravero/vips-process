require 'vips'
require 'vips-process/version'

module Vips
  module Process
    JPEG  = 'jpeg'.freeze
    PNG   = 'png'.freeze

    ##
    # Manipulate the image with Vips. Saving of the image is delayed until after
    # all the process blocks have been called. Make sure you always return an
    # VIPS::Image object from the block
    #
    # This method yields VIPS::Image for further manipulation.
    #
    # It also raises an Exception if the manipulation failed.
    def manipulate!
      @_on_process  ||= []
      @_vimage      ||= if jpeg?
        VIPS::Image.jpeg  @src, sequential: true
      elsif png?
        VIPS::Image.png   @src, sequential: true
      else
        VIPS::Image.new   @src
      end
      @_vimage = yield @_vimage
    rescue => e
      raise Exception.new("Failed to manipulate file, maybe it is not a supported image? Original Error: #{e}")
    end

    def process!
      if @_vimage
        tmp_name  = @dst.sub /(\.[[:alnum:]]+)$/i, '_tmp\1'
        writer    = writer_class.send :new, @_vimage, @_format_opts

        @_on_process.each { |block| block.call writer }

        writer.write tmp_name
        FileUtils.mv tmp_name, @dst

        reset!
        @dst
      end
    end

    # Allow changing src and chain it afterwards
    def src!(src)
      @src = src
      self
    end

    # Allow changing dst and chain it afterwards
    def dst!(dst)
      @dst = dst
      self
    end

    private def reset!
      @_on_process  = []
      @_format_opts = nil
      @_vimage      = nil
    end

    private def writer_class
      case @_format
      when JPEG then  VIPS::JPEGWriter
      when PNG  then  VIPS::PNGWriter
      else            VIPS::Writer
      end
    end

    private def jpeg?(path = @src); path =~ /.*jpg$/i or path =~ /.*jpeg$/i; end
    private def png?(path = @src);  path =~ /.*png$/i; end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      ##
      # Define a version
      #
      # @param  name    String  the version's name
      # @param  deps    []      the version's dependencies, it's a list of version names
      # @param  &block  block   if you send a block to it
      def version(name, deps = [], &block)
        throw :need_block_or_deps unless block_given? || !deps.empty?

        @@_versions ||= {}
        @@_versions[name] = {deps: deps, block: block}

        define_method "#{name}_version" do |new_dst=nil|
          @dst = new_dst if new_dst
          @@_versions[name][:deps].each { |dep| instance_eval &@@_versions[dep][:block] }
          instance_eval &@@_versions[name][:block]
          process!
        end
      end
    end
  end
end
