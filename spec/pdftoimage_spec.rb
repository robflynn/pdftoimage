require 'spec_helper'
require 'pdftoimage'

describe Pdftoimage do
  it "should have a VERSION constant" do
    Pdftoimage.const_get('VERSION').should_not be_empty
  end
end
