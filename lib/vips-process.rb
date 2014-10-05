require 'vips'
require 'vips-process/version'

module Vips
  module Process
    JPEG  = 'jpeg'.freeze
    PNG   = 'png'.freeze

    def sequential(val=true)
      @_load_opts[:sequential] = val if jpeg? || png?
      self
    end

    ##
    # Manipulate the image with Vips. Saving of the image is delayed until after
    # all the process blocks have been called. Make sure you always return an
    # VIPS::Image object from the block
    #
    # This method yields VIPS::Image for further manipulation.
    def manipulate!
      @_load_opts   ||= {}
      @_on_process  ||= []
      @_type        ||= jpeg? ? :jpeg : (png? ? :png : :new)
      @_vimage      ||= VIPS::Image.send @_type, @src, @_load_opts
      @_vimage        = yield @_vimage
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

    ##
    # Process all versions using and output them in a directory
    #
    # @param  base  String  the base filename/path where the versions will be saved
    def versions!(base=@dst)
      base_dir, base_ext, base_filename = File.file?(base) ?
        [File.dirname(base), File.extname(base), "#{File.basename(base, File.extname(base))}-"] :
        [base, File.extname(@src), nil]

      FileUtils.mkdir_p base_dir unless File.directory?(base_dir) && File.exist?(base_dir)

      self.class.versions.map do |name|
        [name, send("#{name}_version", File.join(base_dir, "#{base_filename}#{name}#{base_ext}"))]
      end
    end

    private def reset!
      @_load_opts   = {}
      @_on_process  = []
      @_format_opts = {}
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
      # A version will then take optional arguments: `new_dst` which sets the output for
      # the version (and reverts back to the previous dt) and `should_process` which tells
      # whether we should process the version after running its code or not - comes in handy to
      # stack them up.
      #
      # @param  name    String  the version's name
      # @param  deps    []      the version's dependencies, it's a list of version names
      # @param  &block  block   if you send a block to it
      def version(name, deps = [], &block)
        throw :need_block_or_deps unless block_given? || !deps.empty?

        versions = class_variable_defined?(:@@_versions) ? class_variable_get(:@@_versions) : {}
        versions[name] = {deps: deps, block: block}
        class_variable_set :@@_versions, versions

        define_method "#{name}_version" do |new_dst=nil, should_process=true|
          # Make sure we have a reference to the old version if it's being changed
          if new_dst
            old_dst = @dst
            @dst = new_dst
          end

          _versions = self.class.class_variable_get :@@_versions

          # Recursively call dependencies but don't process them yet
          _versions[name][:deps].each { |dep| send "#{dep}_version", new_dst, false }

          # Run the version's block
          instance_eval &_versions[name][:block]

          # Process if we were explicitly told to do so
          version_dst = process! if should_process

          # Revert to the old destination if we changed it during the version
          @dst = old_dst if old_dst

          version_dst
        end
      end

      # Get all the version keys
      def versions; class_variable_get(:@@_versions).keys; end
    end
  end
end
