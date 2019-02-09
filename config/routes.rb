Rails.application.routes.draw do
  resources :lignetvaolds
  resources :lignetvas
  resources :paramunolds
  resources :paramuns
  resources :factureolds
  resources :tacheolds
  resources :recetteolds
  resources :depenseolds
  resources :projetolds
  resources :suivis
  resources :projetclones
  resources :depenses
  resources :recettes
  resources :erreurs
  resources :soustraitants
  resources :familletaches
  resources :typetaches
  resources :contacts
  resources :clienteles
  resources :factures
  resources :taches
  resources :projets
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
