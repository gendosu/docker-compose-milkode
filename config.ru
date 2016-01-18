require 'sidekiq'

@redis_url = 'redis://redis/0/'

Sidekiq.configure_client do |config|
  config.redis = { :url => @redis_url, :size => 1, :namespace => 'foo' }
end


require 'sidekiq/web'
run Sidekiq::Web

