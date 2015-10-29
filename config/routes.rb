Rails.application.routes.draw do

  # You can have the root of your site routed with "root"
  root 'static_pages#home'

  # static pages
  StaticPagesController.action_methods.each do |action|
    get "/#{action}", to: "static_pages##{action}", as: "#{action}_page"
  end

  resources :entrants, only: [:new, :create, :index]
end
