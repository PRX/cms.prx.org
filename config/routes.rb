PRX::Application.routes.draw do

  namespace :api do
    scope ':api_version', api_version: 'v1' do

      root to: 'base#entrypoint'
      match '*any', via: [:options], to: 'base#options'

      resources :audio_files do
        get 'original', on: :member
      end

      resources :audio_versions, except: %i[new edit] do
        resources :audio_files, except: %i[new edit]
      end

      resources :stories, except: %i[new edit] do
        get 'random', on: :collection
        post 'publish', on: :member
        post 'unpublish', on: :member
        resources :promos, except: %i[new edit]
        resources :audio_files, except: %i[new edit]
        resources :audio_versions, except: %i[new edit]
        resources :story_images, path: 'images', except: %i[new edit]
        resources :musical_works, except: %i[new edit]
        resources :producers, except: %i[new edit]
        resources :story_distributions, except: %i[new edit]
      end

      resources :series, except: %i[new edit] do
        resources :series_images, path: 'images', except: %i[new edit]
        resources :stories, only: %i[index create]
        resources :audio_version_templates, except: %i[new edit]
        resources :distributions, except: %i[new edit]
      end

      resources :audio_version_templates, except: %i[new edit] do
        resources :audio_file_templates, except: %i[new edit]
      end

      resources :distributions, except: %i[new edit] do
        resources :audio_version_templates, except: %i[new edit]
      end

      resources :accounts, except: %i[new edit destroy] do
        resource :address, except: %i[new edit]
        resource :account_image, path: 'image', except: %i[new edit]
        resources :memberships, only: [:index]
        resources :series, except: %i[new edit]
        resources :stories, only: %i[index create]
        resources :audio_files, only: [:create]
        resources :networks, only: [:index]
      end

      resources :users, except: %i[new edit create destroy] do
        resource :user_image, path: 'image', except: %i[new edit]
        resources :memberships, only: [:index]
        resources :accounts, only: [:index]
      end

      resources :memberships, except: %i[new edit]

      resources :pick_lists, except: %i[new edit] do
        resources :picks, except: %i[new edit]
      end
      resources :picks, except: %i[new edit]

      resources :networks, except: %i[new edit] do
        resources :stories, only: [:index]
      end

      resource :authorization, only: [:show] do
        resources :audio_files, except: %i[new edit]

        resources :accounts, only: %i[index show], module: :auth do
          resources :stories, only: %i[index create update]
        end

        resources :podcast_imports, except: %i[new edit], module: :auth do
          post 'retry', on: :member

          resources :episode_imports, except: %i[new edit] do
            post 'retry', on: :member
          end
        end

        resources :series, except: %i[new edit create], module: :auth do
          resources :stories, only: %i[index create]
        end

        resources :stories, except: %i[new edit create], module: :auth do
          post 'publish', on: :member
          post 'unpublish', on: :member
        end

        resources :networks, only: %i[index show], module: :auth do
          resources :stories, only: [:index]
        end
      end
    end
  end

  match '/api', via: [:get], to: redirect('/api/v1')
  match '/', via: [:get], to: redirect('/api/v1')

  public_asset = 'pub/:token/:expires/:use/:class/:id/:version/:name(.:extension)'
  public_name = { name: /[^\/]+/ }
  match public_asset, to: 'public_assets#show_head', via: :head, constraints: public_name
  match public_asset, to: 'public_assets#show_options', via: :options, constraints: public_name
  match public_asset, to: 'public_assets#show', via: :get, constraints: public_name,
                      as: :public_asset
end
