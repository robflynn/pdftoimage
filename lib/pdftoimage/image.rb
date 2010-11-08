module PDFToImage

  class Image
    attr_reader :filename
    attr_reader :width
    attr_reader :height
    attr_reader :format
    attr_reader :page

    def initialize(filename)
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
    def save(outname)
      cmd = "convert #{@filename} #{outname}"

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
