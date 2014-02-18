PRX::Application.routes.draw do

  namespace :api do
    scope ':api_version', format: 'json', api_version: 'v1' do

      root to: 'base#entrypoint'

      resources :audio_files
      resources :audio_versions
      resources :stories
    end
  end

  match '/api', via: [:get], to: redirect("/api/v1")
  match '/', via: [:get], to: redirect("/api/v1")

  get 'pub/:token/:expires/:use/:class/:id/:version/:name.:extension' => 'public_assets#show', as: :public_asset

end
