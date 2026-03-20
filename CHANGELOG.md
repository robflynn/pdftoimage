# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com).

## [0.3.0] - 2026-03-20

### Added
- `PDFToImage.open` now accepts IO objects in addition to file paths (#11)
- `PDFToImage.from_blob` for opening PDFs from raw binary data (#11)
- `Image#save` now accepts IO objects for output, enabling fully in-memory workflows (#11)
- Support for opening PDFs from remote URLs (#16)

### Changed
- Replaced direct ImageMagick CLI calls with MiniMagick (#15)

### Removed
- Removed iconv dependency (#17)

## [0.2.1] - 2025-04-08

### Fixed
- "Error determining page count" (#13)
- Updated shellwords dependency to 0.2.0+ (#7)

## [0.2.0] - 2023-04-20

### Fixed
- Use of deprecated `File.exists?` method (#4)
- File paths are now escaped to properly handle spaces and special characters (#3)

### Added
- Specifying dpi resolution is now supported (#5)

## [0.1.7] - 2018-05-01

### Fixed
- Updated yard to resolve a vulnerability

## [0.1.6] - 2011-07-13

### Fixed
- Buggy PDF generators encoding CreationDate and ModDate as UTF-16 instead of ASCII, causing parsing errors

## [0.1.5] - 2011-03-08

### Fixed
- poppler_utils no longer leaves off the extra padded zero

## [0.1.4] - 2010-11-15

### Fixed
- Documents with page counts that are exact powers of 10 not parsing properly due to poppler_utils zero-padding behavior

## [0.1.3] - 2010-11-12

### Fixed
- PDF documents with more than 9 pages not parsing properly (zero-padding issue)

## [0.1.2] - 2010-11-11

### Added
- Support for blocks upon opening a PDF
- `quality` method for JPEG/MIFF/PNG compression levels
- Lazy conversion: PDF conversion is now deferred until saving, improving performance for partial conversions

## [0.1.1] - 2010-11-10

- Initial release
