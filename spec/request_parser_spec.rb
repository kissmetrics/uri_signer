require File.expand_path(File.join(File.dirname(__FILE__), '../lib/uri_signer'))

describe UriSigner::RequestParser do
  before do
    @method = 'GET'
    @raw_uri = "https://api.example.com/core/people.json?_signature=1234&page=12&per_page=34&order=name:desc&select=id&select=guid"
  end

  subject { described_class.new(@method, @raw_uri) }

  it "responds to #http_method" do
    subject.should respond_to(:http_method)
  end

  it "responds to #https?" do
    subject.should respond_to(:https?)
  end

  it "responds to #http?" do
    subject.should respond_to(:http?)
  end

  it "responds to #raw_uri" do
    subject.should respond_to(:raw_uri)
  end

  it "responds to #base_uri" do
    subject.should respond_to(:base_uri)
  end

  it "responds to #parsed_uri" do
    subject.should respond_to(:parsed_uri)
  end

  it "responds to #query_params" do
    subject.should respond_to(:query_params)
  end

  it "responds to #query_params?" do
    subject.should respond_to(:query_params?)
  end

  it "responds to #signature" do
    subject.should respond_to(:signature)
  end

  it "responds to #signature?" do
    subject.should respond_to(:signature?)
  end

  context "With HTML encoded URI String" do
    before do
      @raw_uri = "https://api.kissmetrics.dev/v1/accounts?page=2&amp;per_page=2&amp;_signature=lertaejeT%252BN3M1pCjBZo8gCRK%252BAfTmOquNvMZjmAfGw%253D"
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns the #http_method" do
      subject.http_method.should == "GET"
    end

    it "returns true for #https?" do
      subject.https?.should be_true
    end

    it "returns the #base_uri" do
      subject.base_uri.should == "https://api.kissmetrics.dev/v1/accounts"
    end

    it "returns the query values" do
      subject.query_params.size.should eql(2)
    end

    it "does not return the signature in the query values" do
      subject.query_params.should_not have_key('_signature')
    end

    it "returns true for #query_params?" do
      subject.query_params?.should be_true
    end

    it "includes the proper keys in the query value" do
      subject.query_params.should include('page', 'per_page')
    end

    it "returns the signature from the url" do
      subject.signature.should == "lertaejeT%2BN3M1pCjBZo8gCRK%2BAfTmOquNvMZjmAfGw%3D"
    end

    it "returns true for #signature?" do
      subject.signature?.should be_true
    end
  end

  context "With valid values" do
    it "returns the #http_method" do
      subject.http_method.should == "GET"
    end

    it "returns true for #https?" do
      subject.https?.should be_true
    end

    it "returns false for #http?" do
      subject.http?.should be_false
    end

    it "returns the #base_uri" do
      subject.base_uri.should == "https://api.example.com/core/people.json"
    end

    it "returns the #raw_uri" do
      subject.raw_uri.should == "https://api.example.com/core/people.json?_signature=1234&page=12&per_page=34&order=name:desc&select=id&select=guid"
    end

    it "returns the query values" do
      subject.query_params.size.should eql(4)
    end

    it "does not return the signature in the query values" do
      subject.query_params.should_not have_key('_signature')
    end

    it "returns true for #query_params?" do
      subject.query_params?.should be_true
    end

    it "includes the proper keys in the query value" do
      subject.query_params.should include('page','per_page','order')
    end

    it "returns multiple values for query param key" do
      subject.query_params['select'].should eql ['id', 'guid']
    end

    it "returns the parsed_uri as an Addressable::URI object" do
      subject.parsed_uri.should be_a_kind_of(Addressable::URI)
    end

    it "returns the signature from the url" do
      subject.signature.should == "1234"
    end

    it "returns true for #signature?" do
      subject.signature?.should be_true
    end
  end

  context "without query params" do
    before do
      @raw_uri = "https://api.example.com/core/people.json"
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns empty query values" do
      subject.query_params.size.should eql(0)
    end

    it "returns false for #signature?" do
      subject.signature?.should be_false
    end

    it "returns false for #query_params?" do
      subject.query_params?.should be_false
    end
  end

  context "Determining the scheme" do
    before do
      @raw_uri = "http://api.example.com"
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns false for #https?" do
      subject.https?.should be_false
    end

    it "returns true for #http?" do
      subject.http?.should be_true
    end
  end

  context "With a signature and other query string values in the URI" do
    before do
      @raw_uri = "https://api.example.com/test?page=3&per_page=23&order=name:desc&_signature=3434343434gh="
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns true for #signature?" do
      subject.signature?.should be_true
    end

    it "escapes the signature" do
      subject.signature.should == "3434343434gh%3D"
    end
  end

  context "With a signature and no other query string values in the URI" do
    before do
      @raw_uri = "https://api.example.com/test?_signature=3434343434gh="
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns true for #signature?" do
      subject.signature?.should be_true
    end

    it "escapes the signature" do
      subject.signature.should == "3434343434gh%3D"
    end

    it "returns empty query values" do
      subject.query_params.size.should eql(0)
    end

    it "returns false for #query_params?" do
      subject.query_params?.should be_false
    end
  end

  context "Without a signature in the URI" do
    before do
      @raw_uri = "https://api.example.com"
    end

    subject { described_class.new(@method, @raw_uri) }

    it "returns an empty string for #signature" do
      subject.signature.should be_empty
    end

    it "returns false for #signature?" do
      subject.signature?.should be_false
    end
  end

  context "Validations" do
    it "raises a UriSigner:MissingHttpMethodError if an empty string is provided" do
      lambda { described_class.new('', @raw_uri)}.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end

    it "raises a UriSigner::MissingHttpMethodError if nil is provided" do
      lambda { described_class.new(nil, @raw_uri)}.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end
  end
end
