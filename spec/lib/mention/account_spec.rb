require 'spec_helper_unit'

describe Mention::Account do
  let(:account){ Mention::Account.new(account_id: 'abc', access_token: 'def') }

  it "queries a list of alerts" do
    stub_request(:get, "https://api.mention.net/api/accounts/abc/alerts").
      with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer def', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("spec/fixtures/get_account_alerts.json"))

    account.alerts.size.should == 1
    account.alerts.first.should be_a(Mention::Alert)
  end

  it "queries basic information about the account" do
    stub_request(:get, "https://api.mention.net/api/accounts/abc").
      with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer def', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => File.read("spec/fixtures/get_account.json"))

    account.id.should == 'abc'
    account.name.should == "Michael Ries"
    account.email.should == 'michael@riesd.com'
    account.created_at.should == Time.parse("2013-10-06T22:09:48.0+00:00")
  end

  it "can add alerts to an account" do
    stub_request(:post, "https://api.mention.net/api/accounts/abc/alerts").
      with(:body => "{\"name\":\"ROM\",\"primary_keyword\":\"ROM\",\"included_keywords\":[],\"excluded_keywords\":[],\"required_keywords\":[\"ruby\",\"object\",\"mapper\"],\"noise_detection\":true,\"sentiment_analysis\":false,\"languages\":[\"en\"],\"sources\":[\"web\",\"facebook\",\"twitter\",\"news\",\"blogs\",\"videos\",\"forums\",\"images\"]}",
          :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer def', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => File.read("spec/fixtures/post_account_alerts.json"))

    alert = Mention::Alert.new(name: 'ROM', primary_keyword: 'ROM', required_keywords: ['ruby','object','mapper'])
    alert = account.add(alert)
    alert.id.should == '461518'
    alert.name.should == 'ROM'
  end

  it "reports validation errors when creating a new alert" do
    pending
    stub_request(:post, "https://api.mention.net/api/accounts/abc/alerts").
      with(:body => {"name"=>"ROM", "noise_detection"=>true, "primary_keyword"=>"ROM", "required_keywords"=>["ruby", "object", "mapper"], "sentiment_analysis"=>false},
          :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Authorization'=>'Bearer def', 'Content-Length'=>'302', 'Content-Type'=>'application/json'}).
      to_return(:status => 200, :body => File.read("spec/fixtures/post_account_alerts_failed.json"))    

    alert = Mention::Alert.new(name: 'ROM', primary_keyword: 'ROM', required_keywords: ['ruby', 'object', 'mapper'])
    ->{
      account.add(alert)
    }.should raise_error(Mention::ValidationError, /language/)
  end
end
