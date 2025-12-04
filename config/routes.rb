Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'stock_update#index'
  get 'stock_update/index'
  post 'stock_update/execute'
  
  # RoutingError
  # 上から順に評価されるので、一番下に書く
  get '*path', controller: 'application', action: 'error_404'
end
