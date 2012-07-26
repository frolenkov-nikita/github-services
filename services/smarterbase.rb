class Service::Smarterbase < Service
  default_events :commit_comment, :issues, :issue_comment
  string   :subdomain, :username
  password :password
  white_list :subdomain, :username
 
  def invalid_request?
    data['username'].to_s.empty? or
        data['password'].to_s.empty? or
        data['subdomain'].to_s.empty?
  end

  def service_url(subdomain)
    if subdomain =~ /\./
      url = "http://#{subdomain}/external/github"
    else
      url = "http://#{subdomain}.smarterbase.com/external/github"
    end

    begin
      Addressable::URI.parse(url)
    rescue Addressable::URI::InvalidURIError
      raise_config_error("Invalid subdomain #{subdomain}")
    end

    url
  end

  def receive_event
    raise_config_error "Bad configuration" if invalid_request?
    puts event.to_s
    http.headers['X-GitHub-Event'] = event.to_s

    url = service_url(data['subdomain'])
    res = http_post(url, { :payload => payload,
                           :subdomain => data['subdomain'],
                           :username => data['username'],
                           :password => data['password'] }.to_json)
    
    unless res.status.to_s[/2\d+/]
      raise_config_error("Unexpected response code:#{res.status}")
    end
  end
end
