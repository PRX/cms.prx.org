PRX::Application.routes.draw do

  namespace :api do
    scope ':api_version', api_version: 'v1' do

      root to: 'base#entrypoint'
      match '*any', via: [:options], to: 'base#options'

      resources :audio_files
      resources :account_images, only: [:show, :index]
      resources :series_images, only: [:show, :index]
      resources :story_images, only: [:show, :index]
      resources :user_images, only: [:show, :index]

      resources :audio_versions do
        resources :audio_files, except: [:new, :edit]
      end

      resources :stories, except: [:new, :edit] do
        get 'random', on: :collection
        post 'publish', on: :member
        post 'unpublish', on: :member
        resources :promos, except: [:new, :edit]
        resources :audio_files, except: [:new, :edit]
        resources :audio_versions, except: [:new, :edit]
        resources :story_images, path: 'images', except: [:new, :edit]
        resources :musical_works, except: [:new, :edit]
        resources :producers, except: [:new, :edit]
      end

      resources :series, except: [:new, :edit] do
        resources :series_images, path: 'images', except: [:new, :edit]
        resources :stories, only: [:index, :post]
      end

      resources :accounts do
        resource :address, except: [:new, :edit]
        resource :account_image, path: 'image', except: [:new, :edit]
        resources :memberships, only: [:index]
        resources :series, except: [:new, :edit]
        resources :stories, only: [:index, :post]
      end

      resources :users do
        resource :user_image, path: 'image', except: [:new, :edit]
        resources :memberships, only: [:index]
        resources :accounts, only: [:index]
      end

      resources :memberships, except: [:new, :edit]

      resources :pick_lists do
        resources :picks
      end
      resources :picks

      resource :authorization, only: [:show] do
        resources :accounts, only: [:index], controller: 'authorizations'
      end
    end
  end

  match '/api', via: [:get], to: redirect("/api/v1")
  match '/', via: [:get], to: redirect("/api/v1")

  get 'pub/:token/:expires/:use/:class/:id/:version/:name.:extension' => 'public_assets#show', as: :public_asset, constraints: {name: /[^\/]+/}

end
