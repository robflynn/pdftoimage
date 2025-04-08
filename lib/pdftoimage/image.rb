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
        attr_reader :pdf_args
        attr_reader :opened

        # ImageMagick methods that we currently support.
        CUSTOM_IMAGE_METHODS = [
            "resize",
            "quality"
        ]

        # pdftoppm methods that we currently support.
        PDF_IMAGE_METHODS = [
            "r",
            "rx",
            "ry",
            "x",
            "y"
        ]

        CUSTOM_IMAGE_METHODS.each do |method|
            define_method(method.to_sym) do |*args|
                @args << "-#{method} #{args.join(' ')}"

                self
            end
        end

        PDF_IMAGE_METHODS.each do |method|
            define_method(method.to_sym) do |*args|
                @pdf_args << "-#{method} #{args.join(' ')}"

                self
            end
        end

        # Image constructor
        #
        # @param pdf_name [String] The name of the PDF
        # @param filename [String] The name of the image for the specified page
        # @param page [Integer] The page number of the PDF
        # @param page_size [Hash] Hash containing width and height dimensions of the page
        # @param page_count [integer] The number of pages in the PDF
        #
        def initialize(pdf_name, filename, page, page_size, page_count)
            @args = []
            @pdf_args = []

            @pdf_name = pdf_name
            @filename = filename
            @opened = false
            @width = page_size[:width]
            @height = page_size[:height]
            @page_count = page_count

            @page = page
        end

        # Saves the converted image to the specified location
        #
        # @param outname [String] The output filename of the image
        #
        def save(outname)
            generate_temp_file

            cmd = "convert "

            if not @args.empty?
                cmd += "#{@args.join(' ')} "
            end

            cmd += "#{Shellwords.escape(@filename)} #{Shellwords.escape(outname)}"

            PDFToImage.exec(cmd)

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

        def width(*args)
            @pdf_args << "-W #{args.join(' ')}"

            self
        end

        def height(*args)
            @pdf_args << "-H #{args.join(' ')}"

            self
        end

      private

        def generate_temp_file
            if @opened == false
                cmd = "pdftoppm -png -f #{@page} #{@pdf_args.join(" ")} -l #{@page} #{Shellwords.escape(@pdf_name)} #{Shellwords.escape(@filename)}"
                PDFToImage.exec(cmd)
                @filename = "#{@filename}-#{page_suffix}.png"
                @opened = true
            end

            return true
        end

        def page_suffix
            cur_page_len = @page.to_s.length
            total_page_len = @page_count.to_s.length

            num_zeroes = total_page_len - cur_page_len

            # This is really weird. Basically, poppler_utils does not
            # prepend a '0' to the page count when the total number of
            # pages is 10, 100, 1000, 10000, etc. I hate putting this here,
            # but whatever...

            # TODO: Keep an eye on this. This suddenly started causing problems.
            # Did poppler_utils change?
            #      if @page_count.to_s.reverse.to_i == 1 && num_zeroes > 0
            #       num_zeroes = num_zeroes - 1
            #      end

            if cur_page_len == total_page_len
                @page
            end

            padded = '0' * num_zeroes + @page.to_s
            padded
        end
    end
end
