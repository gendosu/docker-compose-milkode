#!/bin/bash

# startup milk web
milk web -n -o 0.0.0.0 &

# startup sidekiq
sidekiq -r ./sidekiq.rb -C ./config.yml -L sidekiq.log -d

# startup sidekiq web ui
rackup -p 9000 -o 0.0.0.0 -D
