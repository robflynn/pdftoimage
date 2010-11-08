require 'pdftoimage/version'
require 'pdftoimage/image'

module PDFToImage

  class PDFError << RunetimeError; end

  class << self

    # Opens a PDF document and prepares it for splitting into images.
    #
    # @param [filename] The filename of the PDF to open
    # @return [Array] An array of images
    def open(filename)
    end

  end

end
