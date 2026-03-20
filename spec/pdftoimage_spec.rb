require 'spec_helper'
require 'pdftoimage'
require 'mini_magick'

describe PDFToImage do
    it "should have a VERSION constant" do
        expect(PDFToImage.const_get('VERSION')).not_to be_empty
    end

    #  I will find a better solution for having this commented out. I do not
    #  have permission to release the document that I used for this test case.
    #  I will generate a sufficiently buggy version.  Basically, buggy PDF software
    #  sometimes corrupts CreationDate and/or ModDate such as discussed here: http://www.linuxquestions.org/questions/solaris-opensolaris-20/converting-utf-16-files-to-another-encoding-such-as-utf-8-a-630588/
    #  I also need to come upw ith a better solution

    #  describe "edge cases" do
    #    it "should handle invalid utf-8 in headers without crashing" do
    #       @pages = PDFToImage.open('spec/weird_utf8.pdf')
    #   @pages.size.should equal 1
    #   @pages[0].resize('50%').save('spec/tmp1.jpg')
    #   File.exist?('spec/tmp1.jpg').should equal true
    #   File.unlink('spec/tmp1.jpg')
    #    end
    #  end

    describe "3pages.pdf" do
        it "should have three pages" do
            @pages = PDFToImage.open('spec/3pages.pdf')
            expect(@pages.size).to eq(3)
        end

        it "should allow saving" do
            @pages = PDFToImage.open('spec/3pages.pdf')
            @pages.each do |page|
                page.save('spec/tmp.jpg')
                file_exists = File.exist?('spec/tmp.jpg')
                expect(file_exists).to eq(true)
                File.unlink('spec/tmp.jpg')
            end
        end

        it "should allow resizing and quality control" do
            @pages = PDFToImage.open('spec/3pages.pdf')
            @pages[0].resize('50%').quality('80%').save('spec/tmp2.jpg')
            expect(File.exist?('spec/tmp2.jpg')).to eq(true)
            File.unlink('spec/tmp2.jpg')
        end

        it "should work with blocks" do
            counter = 0
            PDFToImage.open("spec/3pages.pdf") do |page|
                counter = counter + 1
            end
            expect(counter).to eq(3)
        end

        it "should use Shellwords to escape filenames" do
            counter = 0
            PDFToImage.open("spec/include blanks.pdf") do |page|
                counter = counter + 1
            end
            expect(counter).to eq(3)
        end
    end

    describe "multi page documents" do
        it "should parse 10 page documents properly" do
            counter = 0
            PDFToImage.open('spec/10pages.pdf') do |page|
                result = page.save("spec/10pg-#{page.page}.jpg")
                file_exists = File.exist?("spec/10pg-#{page.page}.jpg")
                expect(file_exists).to eq(true)
                File.unlink("spec/10pg-#{page.page}.jpg")
                counter = counter + 1
            end

            expect(counter).to eq(10)
        end

        it "should parse 11 page counts" do
            counter = 0
            PDFToImage.open('spec/11pages.pdf') do |page|
                result = page.save("spec/11pg-#{page.page}.jpg")
                file_exists = File.exist?("spec/11pg-#{page.page}.jpg")
                expect(file_exists).to eq(true)
                File.unlink("spec/11pg-#{page.page}.jpg")
                counter = counter + 1
            end

            expect(counter).to eq(11)
        end

        it "should allow for specifying resolution dpi" do
            # This test is a little weird in that we're setting
            # the value to dpi, but it seems to be stored as
            # a truncated DPCM.  So, 350, for example, should
            # be 137.79527559055118, but it's stored as 137.
            #
            # This keeps us from properly converting between dpcm and dpi
            # and back again.  I'm not sure if this is a bug in the underlying
            # libraries of if that's just the way the spec works, but we'll
            # emulate that here and convert to dpcm before checking.
            target_dpi = 350
            target_dpcm = (target_dpi.to_f / 2.54).to_i

            pages = PDFToImage.open('spec/11pages.pdf')
            page = pages[0]

            # Save the page in 300 dpi
            result = page.r(target_dpi).save("spec/300dpi-test.jpg")

            image = MiniMagick::Image.open("spec/300dpi-test.jpg")

            # Get the resolution
            resolution = image["%x"].to_i

            # Determine which units we're using (DPCM or DPI)
            units = image["%[units]"]

            if units == "PixelsPerInch"
                resolution = (resolution.to_f / 2.54).to_i
            end

            expect(resolution).to eq(target_dpcm)

            File.unlink("spec/300dpi-test.jpg")
        end
    end

    describe "remote URLs" do
        after(:each) do
            @local_pdf&.close
        end

        it "should download and open a PDF from a URL" do
            @local_pdf = File.open('spec/3pages.pdf', 'rb')
            allow(URI).to receive(:open).with("http://example.com/test.pdf").and_return(@local_pdf)

            pages = PDFToImage.open("http://example.com/test.pdf")
            expect(pages.size).to eq(3)
        end

        it "should save pages from a remote PDF" do
            @local_pdf = File.open('spec/3pages.pdf', 'rb')
            allow(URI).to receive(:open).with("http://example.com/test.pdf").and_return(@local_pdf)

            pages = PDFToImage.open("http://example.com/test.pdf")
            pages[0].save('spec/remote_tmp.jpg')
            expect(File.exist?('spec/remote_tmp.jpg')).to eq(true)
            File.unlink('spec/remote_tmp.jpg')
        end

        it "should raise PDFError when download fails" do
            allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new("404 Not Found", StringIO.new))

            expect {
                PDFToImage.open("http://example.com/nonexistent.pdf")
            }.to raise_error(PDFToImage::PDFError, /Failed to download/)
        end
    end

    describe "IO input" do
        it "should open a PDF from an IO object" do
            File.open('spec/3pages.pdf', 'rb') do |io|
                pages = PDFToImage.open(io)
                expect(pages.size).to eq(3)
            end
        end

        it "should open a PDF from a StringIO" do
            data = File.read('spec/3pages.pdf', mode: 'rb')
            io = StringIO.new(data)
            pages = PDFToImage.open(io)
            expect(pages.size).to eq(3)
        end

        it "should save pages from an IO-opened PDF" do
            File.open('spec/3pages.pdf', 'rb') do |io|
                pages = PDFToImage.open(io)
                pages[0].save('spec/io_tmp.jpg')
                expect(File.exist?('spec/io_tmp.jpg')).to eq(true)
                File.unlink('spec/io_tmp.jpg')
            end
        end
    end

    describe "from_blob" do
        it "should open a PDF from binary data" do
            data = File.read('spec/3pages.pdf', mode: 'rb')
            pages = PDFToImage.from_blob(data)
            expect(pages.size).to eq(3)
        end

        it "should save pages from a blob-opened PDF" do
            data = File.read('spec/3pages.pdf', mode: 'rb')
            pages = PDFToImage.from_blob(data)
            pages[0].save('spec/blob_tmp.jpg')
            expect(File.exist?('spec/blob_tmp.jpg')).to eq(true)
            File.unlink('spec/blob_tmp.jpg')
        end

        it "should work with blocks" do
            data = File.read('spec/3pages.pdf', mode: 'rb')
            counter = 0
            PDFToImage.from_blob(data) { |page| counter += 1 }
            expect(counter).to eq(3)
        end
    end

    describe "crop" do
        it "should save a cropped image" do
            pages = PDFToImage.open('spec/3pages.pdf')
            pages[0].crop(0, 0, 100, 100).save('spec/crop_tmp.jpg')
            expect(File.exist?('spec/crop_tmp.jpg')).to eq(true)

            image = MiniMagick::Image.open('spec/crop_tmp.jpg')
            expect(image.width).to eq(100)
            expect(image.height).to eq(100)

            File.unlink('spec/crop_tmp.jpg')
        end

        it "should be chainable with other methods" do
            pages = PDFToImage.open('spec/3pages.pdf')
            pages[0].crop(0, 0, 200, 200).quality('80%').save('spec/crop_chain_tmp.jpg')
            expect(File.exist?('spec/crop_chain_tmp.jpg')).to eq(true)
            File.unlink('spec/crop_chain_tmp.jpg')
        end
    end

    describe "saving to IO" do
        it "should produce identical output to saving to a file" do
            pages = PDFToImage.open('spec/3pages.pdf')

            pages[0].save('spec/io_compare_tmp.jpg')
            file_content = File.read('spec/io_compare_tmp.jpg', mode: 'rb')
            File.unlink('spec/io_compare_tmp.jpg')

            io = StringIO.new(''.b)
            pages[0].save(io)
            io.rewind

            expect(io.read).to eq(file_content)
        end
    end
end
