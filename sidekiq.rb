require 'open3'
require 'sidekiq/web'
require 'uri'
require 'milkode/common/util'

@redis_url = 'redis://redis/0/'

include Milkode::Util

Sidekiq.configure_client do |config|
  config.redis = { :url => @redis_url, :size => 2, :namespace => 'foo' }
end

Sidekiq.configure_server do |config|
  config.redis = { :url => @redis_url, :namespace => 'foo' }

  config.on(:startup) do
    queue = Sidekiq::Queue.new
    queue.clear

    CrawlListWorker.perform_async
  end

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

Sidekiq::Web.app_url = '/'

class EmptyWorker
  include Sidekiq::Worker

  def perform
  end
end

class CrawlWorker
  include Sidekiq::Worker

  def perform(repository)
    redis_url = 'redis://redis/0/'
    # リポジトリをクロールする
    # redisにクロールするリポジトリ一覧持つかな。。
    #   リスト追加
    #     redis.lpushx('crawl_list', 'http://github.com/gendosu/test.git')
    #   リスト取得
    #     redis.lrange('crawl_list', 0, -1)
    #   キュー削除
    #     queues = Sidekiq::Queue.new('foo')
    #     queues.clear
    redis = Redis.new(:url => redis_url)

    redis.lrem('crawl_list', 0, repository)
    redis.lpush('crawl_list', repository)

    if(git_url?(repository))
      repository_name = repository.gsub(/^[^:]*:/, '').gsub(/^\//, "").gsub(/\//, "_").gsub(/\.git$/, "")
    else
      uri = URI.parse(repository)
      repository_name = (uri.path + (uri.query || '')).gsub(/^\//, "").gsub(/\//, "_")
    end

    Open3.popen3("milk add --name=#{repository_name} #{repository}") do |stdin, stdout, stderr, wait_thr|
      if stdout.read.include?('already exist')
        system("milk update #{repository_name}")
      end
    end

  end
end

class CrawlListWorker
  include Sidekiq::Worker

  def perform()
    redis_url = 'redis://redis/0/'
    # リポジトリをクロールする
    # redisにクロールするリポジトリ一覧持つかな。。
    #   リスト追加
    #     redis.lpushx('crawl_list', 'http://github.com/gendosu/test.git')
    #   リスト取得
    #     redis.lrange('crawl_list', 0, -1)
    #   キュー削除
    #     queues = Sidekiq::Queue.new('foo')
    #     queues.clear
    redis = Redis.new(:url => redis_url)

    repositories = redis.lrange('crawl_list', 0, -1)

    repositories.each do |repo|
      CrawlWorker.perform_async(repo)
    end
  end
end

class TimedWorker
  include Sidekiq::Worker

  def perform(start)
    now = Time.now.to_f
    puts "Latency: #{now - start} sec"
  end
end
