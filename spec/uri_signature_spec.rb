require File.expand_path(File.join(File.dirname(__FILE__), '../lib/uri_signer'))

describe UriSigner::UriSignature do
  before do
    @signature_string = "GET&https://test.example.com"
    @secret = "abcd1234"
  end

  subject { described_class.new(@signature_string, @secret) }

  it "responds to #signature_string" do
    subject.should respond_to(:signature_string)
  end

  it "responds to #signature" do
    subject.should respond_to(:signature)
  end

  it "signs the request" do
    # NOTE: Want to somehow refactor this when looking into the players of signing (String Helpers)
    subject.signature.should == "KwLgbFRjaoQ8IBQs3xje6uhgyoT6gQR04YQs36lAXmk%3D"
  end

  context "Validations" do
    it "raises UriSigner::MissingSignatureStringError when empty string is provided" do
      lambda { described_class.new('', @secret) }.should raise_error(UriSigner::Errors::MissingSignatureStringError)
    end

    it "raises UriSigner::MissingSignatureStringError when nil is provided" do
      lambda { described_class.new(nil, @secret) }.should raise_error(UriSigner::Errors::MissingSignatureStringError)
    end

    it "raises UriSigner::MissingSecretError when empty string is provided" do
      lambda { described_class.new(@signature_string, '') }.should raise_error(UriSigner::Errors::MissingSecretError)
    end

    it "raises UriSigner::MissingSecretError when nil is provided" do
      lambda { described_class.new(@signature_string, nil) }.should raise_error(UriSigner::Errors::MissingSecretError)
    end
  end
end
