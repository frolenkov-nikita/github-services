require File.expand_path("../helper", __FILE__)

class SmarterbaseTest < Service::TestCase
  def setup
    @stubs   = Faraday::Adapter::Test::Stubs.new
    @data    = { "username" => "user", "password" => "pass", "subdomain" => "test_subdomain" }
    @payload = { :message => "Some message" }
  end

  def test_subdomain
    post(@data)
    svc = service :event, @data, @payload
    svc.receive_event
  end

  def test_domain
    @data.merge("subdomain" => "test_subdomain.smarterbase.com")

    post(@data)
    
    svc = service :event, @data, @payload
    svc.receive_event
  end


  def post(data)
    @stubs.post "/external/github" do |env|
      assert_equal "test_subdomain.smarterbase.com", env[:url].host
      assert_equal ({ :payload => @payload }.merge(@data).to_json), env[:body]
      [ 201, {}, "" ]
    end
  end

  def service(*args)
    super Service::Smarterbase, *args
  end
end
