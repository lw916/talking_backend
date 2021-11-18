# 此初始化文件初始化使用redis和redis常量（包括每次启动redis清空数据库内容）
require 'redis-namespace'

# 设置redis连接 @todo 注意设置修改为docker内redis地址
redis_connection = Redis.new(:host => Const::REDIS_URL, :port => Const::REDIS_PORT)
# 清空redis数据
redis_connection.flushall

# 用户登陆锁，禁止用户多点登陆
$Connection_lock = Redis::Namespace.new(:Connection_Lock, redis: redis_connection)
# 用户离线时间，超时踢出频道
$Online_time = Redis::Namespace.new(:Online_time, redis: redis_connection)
# 频道在线用户列表
$Online_user_list = Redis::Namespace.new(:Online_user_list, redis: redis_connection)
# 频道语音锁
$Talk_lock = Redis::Namespace.new(:Talk_lock, redis: redis_connection)
