Flexirest::Base.faraday_config do |faraday|
  # since this is attached to Flexirest::Base
  # It may be overwritten when other flexirest
  # objects get initialized. Best to keep this gem
  # near the bottom of the gem file
  faraday.adapter(:net_http)
  faraday.options.timeout       = 120
  faraday.headers['User-Agent'] = "Flexirest/#{Flexirest::VERSION}"
  faraday.headers['Connection'] = "Keep-Alive"
  faraday.headers['Accept']     = "application/json"
  faraday.ssl['verify']         =  Rails.env.production? ? true : false
end