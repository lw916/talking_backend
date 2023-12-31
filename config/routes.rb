Rails.application.routes.draw do

  post '/login' => 'login#login'
  get '/test' => 'login#test'
  post '/logout' => 'login#logout'
  post '/forget' => 'login#forget'
  post '/reset' => 'login#reset'
  post '/register' => 'login#register'
  post '/upload_avatar' => 'login#upload_avatar'
  post '/avatar' => 'login#avatar'
  post '/logs' => 'log#index'
  get '/notify' => 'notifies#index'

  post '/comment' => 'comment#create'
  get '/comment' => 'comment#index'
  get '/avatar' => 'user#return_avatar'
  get '/avatar_get' => 'user#return_all'
  get '/message' => 'message#index'
  post '/message' => 'send#index'

end
