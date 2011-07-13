# -*- encoding: utf-8 -*-
require 'ore'

begin
  Ore::Specification.new do |gemspec|
    # custom logic here
  end
rescue NameError
  STDERR.puts "The 'pdftoimage.gemspec' file requires Ore."
  STDERR.puts "Run `gem install ore-core` to install Ore."
end
