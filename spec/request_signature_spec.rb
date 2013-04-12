require File.expand_path(File.join(File.dirname(__FILE__), '../lib/uri_signer'))

describe UriSigner::RequestSignature do
  before do
    @method = "GET"
    @base_uri = 'https://example.com/members.json'
    @query_params = { "page" => 5, "per_page" => 15 }
  end

  subject { described_class.new(@method, @base_uri, @query_params) }

  it "responds to #http_method" do
    subject.should respond_to(:http_method)
  end

  it "responds to #base_uri" do
    subject.should respond_to(:base_uri)
  end

  it "responds to #encoded_base_uri" do
    subject.should respond_to(:encoded_base_uri)
  end

  it "responds to #query_params" do
    subject.should respond_to(:query_params)
  end

  it "responds to #query_params?" do
    subject.should respond_to(:query_params?)
  end

  it "responds to #encoded_query_params" do
    subject.should respond_to(:encoded_query_params)
  end

  it "responds to #signature" do
    subject.should respond_to(:signature)
  end

  context "with duplicate values for a query string param" do
    before do
      @query_params = { "format" => ['json', 'json'], 'where' => ["name:nate", "name:nate"] }
    end

    subject { described_class.new(@method, @base_uri, @query_params) }

    it "returns the encoded query params" do
      subject.encoded_query_params.should == "format%3Djson%26format%3Djson%26where%3Dname%3Anate%26where%3Dname%3Anate"
    end
  end

  context "with multiple keys in the query string" do
    before do
      @query_params = {"order"=>["name:desc", "id:desc"], "where"=>["name:nate", "id:123"]}
    end

    subject { described_class.new(@method, @base_uri, @query_params) }

    it "returns the #signature string" do
      subject.signature.should == "GET&https%3A%2F%2Fexample.com%2Fmembers.json&order%3Dname%3Adesc%26order%3Did%3Adesc%26where%3Dname%3Anate%26where%3Did%3A123"
    end
  end

  context "Handling the signature" do
    it "returns the #signature string" do
      subject.signature.should == "GET&https%3A%2F%2Fexample.com%2Fmembers.json&page%3D5%26per_page%3D15"
    end

    it "removes the trailing ampersand if not query params are provided" do
      sig = described_class.new(@method, @base_uri, {})
      sig.signature.should == "GET&https%3A%2F%2Fexample.com%2Fmembers.json"
    end
  end

  context "Handling the HTTP Method" do
    it "returns 'GET' for the #http_method" do
      subject.http_method.should == "GET"
    end

    it "allows you to specify the HTTP method in lowercase" do
      sig = described_class.new('get', @base_uri, @query_params)
      sig.http_method.should == "GET"
    end
  end

  context "Handling the base_uri" do
    it "returns 'https://example.com/members.json' for the #base_uri" do
      subject.base_uri.should == "https://example.com/members.json"
    end

    it "returns the #encoded_base_uri" do
      subject.encoded_base_uri.should == "https%3A%2F%2Fexample.com%2Fmembers.json"
    end
  end

  context "Handling the Query Params" do
    it "returns the page and per_page query params" do
      subject.query_params.keys.should include('page', 'per_page')
    end

    it "converts the keys to strings" do
      sig = described_class.new(@method, @base_uri, { :page => 4, :per_page => 35 })
      sig.query_params.keys.should include('page', 'per_page')
    end

    it "returns true for #query_params?" do
      subject.query_params?.should be_true
    end

    it "returns the sorted and #encoded_query_params" do
      subject.encoded_query_params.should == "page%3D5%26per_page%3D15"
    end
  end

  context "Handling when no Query Params are provided" do
    subject { described_class.new(@method, @base_uri, {}) }

    it "returns an empty hash for query_params" do
      subject.query_params.should == {}
    end

    it "returns false for #query_params?" do
      subject.query_params?.should be_false
    end
  end

  context "Validating the HTTP Method" do
    it "raises a UriSigner::MissingHttpMethodError when empty string is provided" do
      lambda { described_class.new('', @base_uri, @query_params) }.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end

    it "raises a UriSigner::MissingHttpMethodError when nil is provided" do
      lambda { described_class.new(nil, @base_uri, @query_params) }.should raise_error(UriSigner::Errors::MissingHttpMethodError)
    end
  end

  context "Validating the Base URI" do
    it "raises a UriSigner::MissingBaseUriError when empty string is provided" do
      lambda { described_class.new(@method, '', @query_params) }.should raise_error(UriSigner::Errors::MissingBaseUriError)
    end

    it "raises a UriSigner::MissingBaseUriError when nil is provided" do
      lambda { described_class.new(@method, nil, @query_params) }.should raise_error(UriSigner::Errors::MissingBaseUriError)
    end
  end
end
