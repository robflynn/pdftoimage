require 'pdftoimage/version'
require 'pdftoimage/image'

require 'tmpdir'
require 'iconv'
require 'shellwords'

module PDFToImage
    class PDFError < RuntimeError; end
end

module PDFToImage
    # A class variable for storing the location of our temp folder
    @@pdf_temp_dir = File.join(Dir.tmpdir())

    begin
        tmp = `pdftoppm -v 2>&1`
        raise(PDFToImage::PDFError, "poppler_utils not installed") unless tmp.index('Poppler')
    rescue Errno::ENOENT
        raise PDFToImage::PDFError, "poppler_utils not installed"
    end

    begin
        tmp = `identify -version 2>&1`
        raise(PDFToImage::PDFError, "ImageMagick not installed") unless tmp.index('ImageMagick')
    rescue Errno::ENOENT
        raise PDFToImage::PDFError, "ImageMagick not installed"
    end

    class << self
        # Opens a PDF document and prepares it for splitting into images.
        #
        # @param filename [String] The filename of the PDF to open
        #
        # @return [Array] An array of images
        def open(filename, &block)
            if not File.exist?(filename)
                raise PDFError, "File '#{filename}' not found."
            end

            pages = page_count(filename)

            # Array of images
            images = []

            1.upto(pages) { |n|
                dimensions = page_size(filename, n)
                image = Image.new(filename, random_filename, n, dimensions, pages)
                images << image
            }

            images.each(&block) if block_given?

            return images
        end

        # Executes the specified command, returning the output.
        #
        # @param cmd [String] The command to run
        # @return [String] The output of the command
        def exec(cmd, error = nil)
            output = `#{cmd}`
            if $? != 0
                if error == nil
                    raise PDFError, "Error executing command: #{cmd}"
                else
                    raise PDFError, error
                end
            end

            return output
        end

        private

        def page_size(filename, page)
            cmd = "pdfinfo -f #{page} -l #{page} #{Shellwords.escape(filename)} | grep -a Page"
            output = exec(cmd)

            matches = /^Page.*?size:.*?(\d+).*?(\d+)/.match(output)
            if matches.nil?
                raise PDFError, "Unable to determine page size."
            end

            scale = 2.08333333333333333
            dimension = {
                width: (matches[1].to_i * scale).to_i,
                height: (matches[2].to_i * scale).to_i
            }

            dimension
        end

        def page_count(filename)
            cmd = "pdfinfo #{Shellwords.escape(filename)} | grep -a Pages"
            output = exec(cmd)
            matches = /^Pages:.*?(\d+)$/.match(output)
            if matches.nil?
                raise PDFError, "Error determining page count."
            end

            return matches[1].to_i
        end

        # Generate a random file name in the system's tmp folder
        def random_filename
            File.join(@@pdf_temp_dir, random_name)
        end

        # Generate a random name of {#length} characters.
        def random_name(length = 15)
            @@chars ||= ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
            return 'pdftoimage-' + Array.new(length, '').collect { @@chars[rand(@@chars.size)] }.join
        end
    end
end
