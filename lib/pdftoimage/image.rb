module PDFToImage

  class Image
    attr_reader :filename
    attr_reader :width
    attr_reader :height
    attr_reader :format
    attr_reader :page
    attr_reader :args

    # We currently only support resizing, as that's all I need at the moment
    # selfish, but I need to return to the main project
    CUSTOM_IMAGE_METHODS = [
      "resize"
    ]

    CUSTOM_IMAGE_METHODS.each do |method|
      define_method(method.to_sym) do |*args|
        @args << "-#{method} #{args.join(' ')}"

        self
      end
    end

    def initialize(filename)
      @args = []

      @filename = filename

      info = identify()

      @width = info[:width]
      @height = info[:height]
      @format = info[:format]

      tmp_base = File.basename(filename, File.extname(filename))
      pieces = tmp_base.split('-')
      @page = pieces[-1].to_i
    end

    # Saves the converted image to the specified location
    #
    # @param [outname] The output filename of the image
    # @param [options] Optional arguments to use when saving the image
    #
    # Example of saving
    #
    # image.save("~/foo.jpg")
    # image.save("~/bar.jpg", :scale => '50%')
    #
    def save(outname)
      cmd = "convert "

      if not @args.empty?
        cmd += "#{@args} "
      end
      
      cmd += "#{@filename} #{outname}"

      `#{cmd}`
      if $? != 0
        raise PDFError, "Error converting file: #{cmd}"
      end

      return true
    end

    def <=>(img)
      if @page == img.page
        return 0
      elsif @page < img.page
        return -1
      else
        return 1
      end
    end

    private 

    def identify
      cmd = "identify #{@filename}"

      result = `#{cmd}`
      unless $?.success?
        raise PDFToImage::PDFError, "Error executing #{cmd}"
      end

      info = result.strip.split(' ')
      dimensions = info[2].split('x')

      return {
        :format => info[1],
        :width => dimensions[0],
        :height => dimensions[1]
      }
    end

  end

end
