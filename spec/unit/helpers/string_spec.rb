require File.expand_path(File.join(File.dirname(__FILE__), '../../../lib/uri_signer'))

describe UriSigner::Helpers::String do
  before(:each) do
    @string = "this is the string"
    @string.extend(UriSigner::Helpers::String)
  end

  context "Escaping with Rack::Utils" do
    subject  { "This & That = Your's + Mine"}

    it "escapes the string properly" do
      subject.extend(UriSigner::Helpers::String).escaped.should == "This+%26+That+%3D+Your%27s+%2B+Mine"
    end
  end

  context "Unescaping with Rack::Utils" do
    subject { "This+%26+That+%3D+Your%27s+%2B+Mine" }

    it "unescapes the string properly" do
      subject.extend(UriSigner::Helpers::String).unescaped.should == "This & That = Your's + Mine"
    end
  end

  context "Base64 encoding" do
    subject { "abcd\n" }

    it "base64 encodes the string and removes the newline character at the end" do
      Base64.stub!(:encode64).and_return("bcdf\n")
      subject.extend(UriSigner::Helpers::String).base64_encoded.should == "bcdf"
    end
  end

  context "URI Parsed string" do
    subject { "https://example.com/core/person.json" }

    it "returns an Addressable parsed URI" do
      subject.extend(UriSigner::Helpers::String).to_parsed_uri.should be_a_kind_of(Addressable::URI)
    end
  end
end
