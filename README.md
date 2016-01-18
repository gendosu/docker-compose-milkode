* milkodeの起動

$> docker-compose up -d

* sidekiqの起動

docker exec -it [milkode_main_container_id] /bin/bash
$> sidekiq -r ./sidekiq.rb -C ./config.yml

* sidekiqのweb UIの起動

docker exec -it [milkode_main_container_id] /bin/bash
$> rackup -p 9000 -o 0.0.0.0
