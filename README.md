* milkodeの起動

docker-compose up -d

* sidekiqの起動

sidekiq -r ./sidekiq.rb -C ./config.yml

