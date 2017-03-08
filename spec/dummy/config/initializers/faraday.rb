Flexirest::Base.faraday_config do |faraday|
  faraday.adapter(:net_http)
  faraday.options.timeout       = 30
  faraday.headers['User-Agent'] = "Flexirest/#{Flexirest::VERSION}"
  faraday.headers['Connection'] = "Keep-Alive"
  faraday.headers['Accept']     = "application/json"
  faraday.ssl['verify']         =  Rails.env.production? ? true : false
end
