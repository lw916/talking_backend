#!/bin/sh
#bundle install
#rails db:create
#rails db:migrate
#rails db:seed
rm -f tmp/pids/server.pid
rails s -b 0.0.0.0 -p 3000