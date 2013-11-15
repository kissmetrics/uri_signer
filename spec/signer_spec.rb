require File.expand_path(File.join(File.dirname(__FILE__), '../lib/uri_signer'))

describe UriSigner::Signer do
  before do
    @http_method = :get
    @uri = "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"
    @secret = "my_secret"
  end

  subject { described_class.new(@http_method, @uri, @secret) }

  it "responds to #uri" do
    subject.should respond_to(:uri)
  end

  it "responds to #http_method" do
    subject.should respond_to(:http_method)
  end

  it "responds to #signature" do
    subject.should respond_to(:signature)
  end

  it "responds to #uri_with_signature" do
    subject.should respond_to(:uri_with_signature)
  end

  it "responds to #valid?" do
    subject.should respond_to(:valid?)
  end

  it "returns the #uri" do
    subject.uri.should == "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name"
  end

  it "returns the upcased #http_method" do
    subject.http_method.should == "GET"
  end

  it "returns the signed URI with the secret" do
    subject.signature.should == "1AaJvChjz+ZYJKxWsUQWNK1a+eGjpCs6uwQKwPw1/V8="
  end

  context "appending the signature" do
    it "appends the _signature on to the URI" do
      subject.uri_with_signature.should == "https://api.example.com/core/people.json?page=5&per_page=25&order=name:desc&select=id,name&_signature=1AaJvChjz+ZYJKxWsUQWNK1a+eGjpCs6uwQKwPw1/V8="
    end

    it "appends the _signature when there are no query string params" do
      uri = "https://api.example.com/core/people.json"
      signer = described_class.new(@http_method, uri, @secret)
      signer.uri_with_signature.should == "https://api.example.com/core/people.json?_signature=6G4xiABih7FGvjwB1JsYXoeETtBCOdshIu93X1hltzk="
    end
  end

  context "Validating the signature" do
    it "returns true for #valid?" do
      subject.valid?('1AaJvChjz+ZYJKxWsUQWNK1a+eGjpCs6uwQKwPw1/V8=').should be_true
    end

    it "returns false for #valid?" do
      subject.valid?('invalid').should be_false
    end
  end

  context "Exception handling" do
    it "raises a UriSigner::MissingHttpMethodError if an empty string is provided" do
      lambda { described_class.new('', @uri, @secret) }.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end

    it "raises a UriSigner::MissingHttpMethodError if nil is provided" do
      lambda { described_class.new(nil, @uri, @secret) }.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end

    it "raises a UriSigner::MissingUriError if an empty string is provided" do
      lambda { described_class.new(@http_method, '', @secret) }.should raise_error(UriSigner::Errors::MissingUriError)
    end

    it "raises a UriSigner::MissingUriError if nil is provided" do
      lambda { described_class.new(@http_method, nil, @secret) }.should raise_error(UriSigner::Errors::MissingUriError)
    end

    it "raises a UriSigner::MissingSecretError if an empty string is provided" do
      lambda { described_class.new(@http_method, @uri, '') }.should raise_error(UriSigner::Errors::MissingSecretError)
    end

    it "raises a UriSigner::MissingSecretError if nil is provided" do
      lambda { described_class.new(@http_method, @uri, nil) }.should raise_error(UriSigner::Errors::MissingSecretError)
    end
  end
end
