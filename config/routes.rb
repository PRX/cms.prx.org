PRX::Application.routes.draw do

  namespace :api do
    scope ':api_version', format: 'json', api_version: 'v1' do

      root to: 'base#entrypoint'

      resources :account_images
      resources :addresses
      resources :audio_files
      resources :licenses
      resources :memberships
      resources :musical_works
      resources :producers
      resources :series_images
      resources :story_images
      resources :user_images

      resources :audio_versions do
        get 'audio_files',    to: 'audio_files#index'        
      end

      resources :stories do
        get 'audio_files',    to: 'audio_files#index'
        get 'audio_versions', to: 'audio_versions#index'
        get 'images',         to: 'story_images#index'
        get 'musical_works',  to: 'musical_works#index'
        get 'producers',      to: 'producers#index'
      end

      resources :series do
        get 'images',         to: 'series_images#index'
        get 'stories',        to: 'stories#index'
      end

      resources :accounts do
        get 'images',         to: 'account_images#index'
        get 'memberships',    to: 'memberships#index'
        get 'series',         to: 'series#index'
        get 'stories',        to: 'stories#index'
      end

      resources :users do
        get 'accounts',       to: 'accounts#index'
        get 'images',         to: 'user_images#index'
        get 'memberships',    to: 'memberships#index'
      end

    end
  end

  match '/api', via: [:get], to: redirect("/api/v1")
  match '/', via: [:get], to: redirect("/api/v1")

  get 'pub/:token/:expires/:use/:class/:id/:version/:name.:extension' => 'public_assets#show', as: :public_asset

end
