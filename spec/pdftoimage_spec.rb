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

    it "should allow saving" do
      @pages = PDFToImage.open('spec/3pages.pdf')
      @pages[0].save('spec/tmp.jpg')
      File.exists?('spec/tmp.jpg').should equal true
      File.unlink('spec/tmp.jpg')
    end

    it "should allow resizing" do
      @pages = PDFToImage.open('spec/3pages.pdf')
      @pages[0].resize('50%').save('spec/tmp2.jpg')
      File.exists?('spec/tmp2.jpg').should equal true
      File.unlink('spec/tmp2.jpg')
    end

    it "should work with blocks" do
      counter = 0
      PDFToImage.open("spec/3pages.pdf") do |page|
        counter = counter + 1
      end
      counter.should equal 3
    end


  end
end
