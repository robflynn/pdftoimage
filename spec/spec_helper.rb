require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require 'rspec'
  require 'pdftoimage/version'

  include PDFToImage
end
