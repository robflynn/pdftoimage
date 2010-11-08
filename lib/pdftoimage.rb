require 'tmpdir'
require 'pdftoimage/version'
require 'pdftoimage/image'

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
    # @param [filename] The filename of the PDF to open
    # @return [Array] An array of images
    def open(filename)
      target_path = random_filename

      if not File.exists?(filename)
        raise PDFError, "File '#{filename}' not found."
      end

      cmd = "pdftoppm -png #{filename} #{target_path}"

      `#{cmd}`
      if $? != 0
        raise PDFError, "Error reading PDF."
      end

      pngs = Dir.glob("#{target_path}*.png")

      images = []

      pngs.each do |png|
        image = Image.new(png)
        images << image
      end

      return images.sort!
    end

    private

    def random_filename
      File.join(@@pdf_temp_dir, random_name)
    end

    def random_name(length = 15)
      @@chars ||= ("a".."z").to_a + ("A".."Z").to_a + ("1".."9").to_a
      return 'pdftoimage-' + Array.new(length, '').collect{@@chars[rand(@@chars.size)]}.join
    end

  end

end
