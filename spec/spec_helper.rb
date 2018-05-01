require 'rubygems'
require 'spork'

Spork.prefork do
    require 'rspec'
    require 'pdftoimage/version'

    include PDFToImage
end

Spork.each_run do
end
