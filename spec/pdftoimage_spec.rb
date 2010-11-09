require 'spec_helper'
require 'pdftoimage'

describe PDFToImage do
  it "should have a VERSION constant" do
    PDFToImage.const_get('VERSION').should_not be_empty
  end

  describe "3pages.pdf" do
    it "should have three pages" do
    @pages = PDFToImage.open('spec/3pages.pdf')
      @pages.size.should equal 3
    end
  end
end
