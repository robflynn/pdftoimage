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
      @pages.each do |page|
        page.save('spec/tmp.jpg')
        File.exists?('spec/tmp.jpg').should equal true
        File.unlink('spec/tmp.jpg')
      end
    end

    it "should allow resizing and quality control" do
      @pages = PDFToImage.open('spec/3pages.pdf')
      @pages[0].resize('50%').quality('80%').save('spec/tmp2.jpg')
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

  describe "multi page documents" do
    it "should parse 10 page documents properly" do
      counter = 0
      PDFToImage.open('spec/10pages.pdf') do |page|
        result = page.save("spec/10pg-#{page.page}.jpg")
        File.exists?("spec/10pg-#{page.page}.jpg").should equal true
        File.unlink("spec/10pg-#{page.page}.jpg")
        counter = counter + 1
      end

      counter.should equal 10
    end

    it "should parse 11 page counts" do
      counter = 0
      PDFToImage.open('spec/11pages.pdf') do |page|
        result = page.save("spec/11pg-#{page.page}.jpg")
        File.exists?("spec/11pg-#{page.page}.jpg").should equal true
        File.unlink("spec/11pg-#{page.page}.jpg")
        counter = counter + 1
      end

      counter.should equal 11
    end


  end
end
