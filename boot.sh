#!/bin/bash

# 使用该命令进行开发模式
if [ $1 = docker_dev ];then
#    cd /talking
#    bundle install
#    rails db:create
#    rails db:migrate
#    rails db:seed
#    rm -f tmp/pids/server.pid
    rails s -b 0.0.0.0 -p 3000
fi
