module PDFToImage

  # A class which is instantiated by PDFToImage when a PDF document
  # is opened.
  class Image
    attr_reader :pdf_name
    attr_reader :filename
    attr_reader :width
    attr_reader :height
    attr_reader :page
    attr_reader :args
    attr_reader :opened

    # ImageMagick methods that we currently support.
    CUSTOM_IMAGE_METHODS = [
      "resize",
      "quality"
    ]

    CUSTOM_IMAGE_METHODS.each do |method|
      define_method(method.to_sym) do |*args|
        @args << "-#{method} #{args.join(' ')}"

        self
      end
    end

    # Image constructor
    #
    # @param [filename] The name of the image file to open
    def initialize(pdf_name, filename, page, page_size)
      @args = []

      @pdf_name = pdf_name
      @filename = filename
      @opened = false
      @width = page_size[:width]
      @height = page_size[:height]

      @page = page
    end

    # Saves the converted image to the specified location
    #
    # @param [outname] The output filename of the image
    #
    def save(outname)

      generate_temp_file

      cmd = "convert "

      if not @args.empty?
        cmd += "#{@args.join(' ')} "
      end
      
      cmd += "#{@filename} #{outname}"

      PDFToImage::exec(cmd)

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

    def generate_temp_file
      if @opened == false
        cmd = "pdftoppm -png -f #{@page} -l #{@page} #{@pdf_name} #{@filename}"
        PDFToImage::exec(cmd)
        @filename = "#{@filename}-#{@page}.png"
        @opened = true
      end

      return true
    end

  end

end
