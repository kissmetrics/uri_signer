require File.expand_path(File.join(File.dirname(__FILE__), '../../../lib/uri_signer'))

describe UriSigner::Helpers::Hash do
  before(:each) do
    @hash = { :first => 'element', 'string' => 'element' }
    @hash.extend(UriSigner::Helpers::Hash)
  end

  it "converts all keys to strings" do
    expect(@hash.stringify_keys.keys).to include("first", "string")
  end
end
