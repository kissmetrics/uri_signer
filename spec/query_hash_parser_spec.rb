require File.expand_path(File.join(File.dirname(__FILE__), '../lib/uri_signer'))

class CustomHash < Hash; end

describe UriSigner::QueryHashParser do
  before do
    @query_hash = { "name" => "bob", "id" => "2344" }
  end

  subject { described_class.new(@query_hash) }

  it "converts the hash to a string" do
    subject.to_s.should == "id=2344&name=bob"
  end

  it "raises a MissingQueryHashError if no hash is provided" do
    lambda { described_class.new('') }.should raise_error(UriSigner::Errors::MissingQueryHashError)
  end

  it "raises a MissingQueryHashError if nil is provided" do
    lambda { described_class.new(nil) }.should raise_error(UriSigner::Errors::MissingQueryHashError)
  end

  it "raises a MissingQueryHashError if a string is provided" do
    lambda { described_class.new('name=bob') }.should raise_error(UriSigner::Errors::MissingQueryHashError)
  end

  it "allows a custom hash to be provided" do
    hash = CustomHash.new
    hash['name'] = 'bob'
    lambda { described_class.new(hash) }.should_not raise_error
  end

  context "one param" do
    before do
      @query_hash = {"order"=>["name:desc", "id:desc"]}
    end

    subject { described_class.new(query_hash) }

    it "converts a single key with multiple values to a string" do
      query_hash = {"order"=>["name:desc", "id:desc"]}
      parser = described_class.new(query_hash)

      parser.to_s.should == "order=name:desc&order=id:desc"
    end

    it "converts a single key value to a string" do
      query_hash = {"order"=>["name:desc"]}
      parser = described_class.new(query_hash)

      parser.to_s.should == "order=name:desc"
    end
  end

  context "Parsing multiple params with different values" do
    before do
      @query_hash = {"order"=>["name:desc", "id:desc"], "_signature"=>"1234", "where"=>["name:nate", "id:123"]}
    end

    subject { described_class.new(@query_hash) }

    it "converts the hash to a string" do
      subject.to_s.should == "_signature=1234&order=name:desc&order=id:desc&where=name:nate&where=id:123"
    end
  end

  context "Parsing multiple params with duplicate values" do
    before do
    @query_hash = {"order"=>["name:desc", "name:desc"], "_signature"=>"1234", "where"=>["name:nate", "name:nate"]}
    end

    subject { described_class.new(@query_hash) }

    it "converts the hash to a string" do
      subject.to_s.should == "_signature=1234&order=name:desc&order=name:desc&where=name:nate&where=name:nate"
    end
  end
end
