Rails.application.routes.draw do

  post '/login' => 'login#login'
  post '/logout' => 'login#logout'
  post '/reset' => 'login#reset'
  post '/register' => 'login#register'
  post '/upload_avatar' => 'login#upload_avatar'
  post '/avatar' => 'login#avatar'

  post '/comment' => 'comment#create'
  get '/comment' => 'comment#index'

end
