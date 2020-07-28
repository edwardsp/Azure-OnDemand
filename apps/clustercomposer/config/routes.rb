Rails.application.routes.draw do
  get 'azhpcclusters/index'
  get 'azhpcclusters/submit'
  get 'azhpcclusters/stop'
  get 'azhpcclusters/start'
  get 'azhpcclusters/delete'
  get 'azhpcclusters/destroy'
  #get 'azhpcclusters/new_from_path'
  get 'azhpcclusters/new_from_url'
  get 'azhpcclusters/copy'
  resources :templates, only: [:new, :create, :destroy]

  resources :workflows do
    member do
      put 'submit'
      put 'stop'
      post 'copy'
    end
  end

  post "create_default" => "azhpcclusters#create_default"
  get "new_from_path" => "azhpcclusters#new_from_path"
  post "create_from_path" => "azhpcclusters#create_from_path"
  root "azhpcclusters#index"
  #post "create_default" => "workflows#create_default"
  #get "new_from_path" => "workflows#new_from_path"
  #post "create_from_path" => "workflows#create_from_path"
  #root "workflows#index"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end