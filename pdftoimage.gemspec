Gem::Specification.new do |s|
    s.name        = 'pdftoimage'
    s.version     = '0.2.0'
    s.summary     = 'A ruby gem for converting PDF documents into a series of images.'
    s.description = 'A ruby gem for converting PDF documents into a series of images. This module is based off poppler_utils and ImageMagick.'
    s.authors     = ['Rob Flynn']
    s.email       = 'rob@thingerly.com'
    s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.rdoc ChangeLog.rdoc)
    s.homepage    = 'https://github.com/robflynn/pdftoimage'
    s.license     = 'MIT'
    s.metadata    = {
        'changelog_uri'     => 'https://github.com/robflynn/pdftoimage/blob/master/ChangeLog.rdoc',
        'source_code_uri'   => 'https://github.com/robflynn/pdftoimage/'
    }

    s.add_dependency 'iconv', '~> 1.0'
    s.add_dependency 'shellwords', '~> 0.1.0'
end
