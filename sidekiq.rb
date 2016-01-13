Sidekiq.configure_client do |config|
  config.redis = { :url => 'redis://redis/0/', :size => 2, :namespace => 'foo' }
end
Sidekiq.configure_server do |config|
  config.redis = { :url => 'redis://redis/0/', :namespace => 'foo' }
  config.on(:startup) { }
  config.on(:quiet) { }
  config.on(:shutdown) do
    #result = RubyProf.stop

    ## Write the results to a file
    ## Requires railsexpress patched MRI build
    # brew install qcachegrind
    #File.open("callgrind.profile", "w") do |f|
      #RubyProf::CallTreePrinter.new(result).print(f, :min_percent => 1)
    #end
  end
end

require 'sidekiq/web'
Sidekiq::Web.app_url = '/'

class EmptyWorker
  include Sidekiq::Worker

  def perform
  end
end

class CrawlWorker
  include Sidekiq::Worker

  def perform
    # リポジトリをクロールする
  end
end

class CrawlListWorker
  include Sidekiq::Worker

  def perform
    # クロールするリポジトリの一覧を更新する
  end
end

class TimedWorker
  include Sidekiq::Worker

  def perform(start)
    now = Time.now.to_f
    puts "Latency: #{now - start} sec"
  end
end
