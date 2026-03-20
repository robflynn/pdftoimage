# pdftoimage

A Ruby gem for converting PDF documents into images using [poppler_utils](https://poppler.freedesktop.org/) and [MiniMagick](https://github.com/minimagick/minimagick).

## Installation

```sh
gem install pdftoimage
```

### Requirements

- [poppler_utils](https://poppler.freedesktop.org/)
- [ImageMagick](https://imagemagick.org/)

## Usage

### From a file

```ruby
require 'pdftoimage'

images = PDFToImage.open('somefile.pdf')
images.each do |page|
  page.resize('50%').save("output/page-#{page.page}.jpg")
end
```

### With a block

```ruby
PDFToImage.open('report.pdf') do |page|
  page.resize('150').quality('80%').save("out/thumbnail-#{page.page}.jpg")
end
```

### From a URL

```ruby
pages = PDFToImage.open('https://example.com/report.pdf')
pages[0].save('first_page.png')
```

### From an IO object

```ruby
File.open('report.pdf', 'rb') do |io|
  pages = PDFToImage.open(io)
  pages[0].save('first_page.png')
end
```

### From binary data

```ruby
pdf_data = download_pdf_from_s3(key)
pages = PDFToImage.from_blob(pdf_data)
pages[0].save('first_page.png')
```

### Saving to an IO object

```ruby
pages = PDFToImage.open('report.pdf')

io = StringIO.new(''.b)
pages[0].save(io)
io.rewind
```

### Setting resolution

```ruby
PDFToImage.open('report.pdf') do |page|
  page.r(350).save("out/hires-#{page.page}.jpg")
end
```

## License

Copyright (c) 2026 Rob Flynn

See [LICENSE](LICENSE) for details.
