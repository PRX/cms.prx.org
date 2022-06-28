PRX::Application.routes.draw do

  namespace :api do
    # TODO: https://github.com/PRX/hal_api-rails/issues/12
    scope ':api_version', api_version: 'v1' do

      root to: 'base#entrypoint'
      match '*any', via: [:options], to: 'base#options'

      resources :audio_files do
        get 'original', on: :member
      end

      resources :audio_versions, except: [:new, :edit] do
        resources :audio_files, except: [:new, :edit]
      end

      resources :stories, except: [:new, :edit] do
        get 'random', on: :collection
        get 'search', on: :collection
        post 'publish', on: :member
        post 'unpublish', on: :member
        resources :promos, except: [:new, :edit]
        resources :audio_files, except: [:new, :edit]
        resources :audio_versions, except: [:new, :edit]
        resources :story_images, path: 'images', except: [:new, :edit]
        resources :musical_works, except: [:new, :edit]
        resources :producers, except: [:new, :edit]
        resources :story_distributions, except: [:new, :edit]
      end

      resources :series, except: [:new, :edit] do
        get 'calendar'
        get 'search', on: :collection
        get 'tags'
        resources :series_images, path: 'images', except: [:new, :edit]
        resources :stories, only: [:index, :create] do
          get 'search', on: :collection
        end
        resources :audio_version_templates, except: [:new, :edit]
        resources :distributions, except: [:new, :edit]
      end

      resources :audio_version_templates, except: [:new, :edit] do
        resources :audio_file_templates, except: [:new, :edit]
      end

      resources :distributions, except: [:new, :edit] do
        resources :audio_version_templates, except: [:new, :edit]
      end

      resources :accounts, except: [:new, :edit, :destroy] do
        resource :address, except: [:new, :edit]
        resource :account_image, path: 'image', except: [:new, :edit]
        resources :memberships, only: [:index]
        resources :series, except: [:new, :edit]
        resources :stories, only: [:index, :create]
        resources :audio_files, only: [:create]
        resources :networks, only: [:index]
      end

      resources :users, except: [:new, :edit, :create, :destroy] do
        resource :user_image, path: 'image', except: [:new, :edit]
        resources :memberships, only: [:index]
        resources :accounts, only: [:index, :create]
      end

      resources :memberships, except: [:new, :edit]

      resources :pick_lists, except: [:new, :edit] do
        resources :picks, except: [:new, :edit]
      end
      resources :picks, except: [:new, :edit]

      resources :networks, except: [:new, :edit] do
        resources :stories, only: [:index]
      end

      resource :authorization, only: [:show] do
        resources :audio_files, except: [:new, :edit]

        resources :accounts, only: [:index, :show], module: :auth do
          resources :stories, only: [:index, :create, :update]
        end

        resources :podcast_imports, except: [:new, :edit], module: :auth do
          post 'retry', on: :member
          get 'verify_rss', on: :collection

          resources :episode_imports, except: [:new, :edit] do
            post 'retry', on: :member
          end

          resources :episode_imports, as: :episode_import_placeholders, path: :episode_import_placeholders, except: [:new, :edit] do
            post 'retry', on: :member
          end
        end

        resources :series, except: [:new, :edit, :create], module: :auth do
          get 'search', on: :collection
          resources :stories, only: [:index, :create] do
            get 'search', on: :collection
          end
          resources :podcast_imports, only: [:index]
        end

        resources :stories, except: [:new, :edit, :create], module: :auth do
          post 'publish', on: :member
          post 'unpublish', on: :member
          get 'search', on: :collection
        end

        resources :networks, only: [:index, :show], module: :auth do
          resources :stories, only: [:index]
        end
      end
    end
  end

  match '/api', via: [:get], to: redirect("/api/v1")
  match '/', via: [:get], to: redirect("/api/v1")

  public_asset = 'pub/:token/:expires/:use/:class/:id/:version/:name(.:extension)'
  public_name = { name: /[^\/]+/ }
  match public_asset, to: 'public_assets#show_head', via: :head, constraints: public_name
  match public_asset, to: 'public_assets#show_options', via: :options, constraints: public_name
  match public_asset, to: 'public_assets#show', via: :get, constraints: public_name,
                      as: :public_asset
end
