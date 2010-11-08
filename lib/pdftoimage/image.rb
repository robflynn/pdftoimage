module PDFToImage

  class Image
    attr_reader :filename
    attr_reader :width
    attr_reader :height
    attr_reader :format

    def initialize(filename)
      @filename = filename

      info = identify()

      @width = info[:width]
      @height = info[:height]
      @format = info[:format]
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
