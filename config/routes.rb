require 'sidekiq/web'
Rails.application.routes.draw do
  get 'paypal_payments/create'
  get 'paypal_payments/get_access_token'
  
  mount Sidekiq::Web => '/sidekiq'
  post '/rate' => 'rater#create', :as => 'rate'
  devise_for :patients, path: "patients", path_names: { sign_in: 'login', sign_out: 'logout',
                                                      sign_up: 'sign_up' },
                        controllers: {registrations: "patients/registrations",
                                      sessions: 'patients/sessions',
                                      passwords: 'patients/passwords',
                                      omniauth_callbacks: "patients/omniauth_callbacks"}

  devise_for :doctors, path: "doctors", path_names: { sign_in: 'login', sign_out: 'logout',
                                                      sign_up: 'sign_up' },
                        controllers: {registrations: "doctors/registrations",
                                      sessions: 'doctors/sessions',
                                      passwords: 'doctors/passwords'}
  # devise_for :agencies, ActiveAdmin::Devise.config
  config = ActiveAdmin::Devise.config
  config[:controllers][:sessions] = "agencies/sessions"
  # config[:controllers][:passwords] = "agencies/passwords"
  config[:controllers][:registrations] = "agencies/registrations"
  devise_for :agencies, config.merge({path: '/agencies'})

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  apipie
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'
  namespace :agencies do
    resources :profiles
    resources :calendars do
      collection do
        get :edit_default_schedule
        put :update_default_schedule
        get "/:doctor_id/custom_schedules_of_doctor" => :custom_schedules_of_doctor
        get "/:doctor_id/calendar_of_doctor" => :calendar_of_doctor
        get :doctor_list
        put :apply_default_schedule
      end
      member do
        get "/:appointment_id/detail_appointment" => :detail_appointment
      end
    end
    resources :appointments, only: [:index, :show]
    resources :helps, only: [:index, :show]
    resources :terms_condititions, only: [:index, :show]
  end
  namespace :doctors do
    resources :profiles
    resources :calendars do
      collection do
        get :edit_event
        put :update_event
        put :apply_default_schedule
        get "/:appointment_id/detail_appointment" => :detail_appointment
      end
    end
    resources :appointments, only: [:index, :show]
    resources :faq_doctors, only: [:index] do
    end
  end
  namespace :patients do
    resources :profiles
    resources :facebooks, only: [:new, :create]
    resources :appointments, except: :destroy do
      member do
        get :track_doctor
      end
    end
    resources :maps do
      collection do
        put :make_appointment
        get :show_make_request
        put :update_location
        get "/:doctor_id/view_doctor", action: :view_doctor
        get :life_threatening
        get :warning
        get :find_and_show_doctor_around
      end
    end
    resources :dashboards
    resources :payments do
      collection do
        get :apply_voucher
        get :edit_histories
        post :create_credit_card
        post :create_paypal
      end
      member do
        patch :update_credit_card
        patch :update_paypal
      end
    end
    resources :locations, except: [:show, :destroy] do
      collection do
        post :create_billing_address
      end
    end
  end
  resources :doctors, only: [:index, :edit, :update, :destroy]
  resources :terms_conditions, only: [:index] do
    collection do
      get :index_mobile
    end
  end
  resources :helps, only: [:index] do
    collection do
      get :index_mobile
      get :patient_faq
    end
  end

  get 'doctors/view' => 'doctors/profiles#view', as: :doctor_view_profile
  get 'doctors/jobs' => 'doctors/profiles#job_history', as: :doctor_job_history
  get 'doctors/payments' => 'doctors/profiles#payment_history', as: :doctor_payment_history
  get 'patients/view' => 'patients/profiles#view', as: :patient_view_profile
  get 'patients/jobs' => 'patients/profiles#appoinment_history', as: :patient_appointment_history
  get 'patients/payments' => 'patients/profiles#payment_history', as: :patient_payment_history

  get 'invoices/get_price_items' => 'invoices#get_price_items'
  get 'invoices/get_item_price' => 'invoices#get_item_price'

  # Redirect after sign up on landing
  get 'sign_up_success', :to => 'home#after_landing_sign_up', as: :after_sign_up_success
  get 'home', :to => 'home#home'

  #For patient
  get 'patients/sign_in_newregister', :to => 'patients/sign_in_newregister#sign_in_newregister'
  # get 'patients/dashboard', :to => 'patients/dashboard#index'

  get 'vouchers/:voucher_code/validate' => "vouchers#validate"

  namespace :api do
    namespace :v1 do
      namespace :patients do
        resources :patients do
          collection do
            put :update_profile
            #get :available_doctors
            get "/:doctor_id/view_doctor_profile" => :view_doctor_profile
            get "/:doctor_id/track_doctor" => :track_doctor
            post :update_paypal_access_token
            get :total_credits
            put :update_device_token

          end
          member do
            get :get_etas_from_patient_to_doctor
            get :available_doctors
            
            post :update_credits
          end
        end
        resources :customer_cares do
          collection do
            get :faq_list
            get :gpdq_email
            get :gpdq_phone
          end
        end
        resources :appointments, only: [:index] do
          collection do
            get :patient_invoice
            get :summary
            get :booking_confirmed
            post :create
            get :doctor_info
            get :price_list
            get :pending_invoice
          end
          member do
            put :cancel_appointment
            put :rating
            get :final_invoice
            get :rating_detail
          end
        end
        resources :registrations do
          collection do
            post :sign_up_with_fb
            post :sign_up
          end
        end

        resources :sessions do
          collection do
            post :login_with_fb
          end
        end

        resources :passwords do
          collection do
            put :forgot
            put :new_password
          end
        end

        resources :maps do
          collection do
            put :save_address
            put :save_billing_address
            get :find_doctor_around
            put :find_doctor_around
            get :get_last_addresses
            put :save_current_location
            put :out_covarage_area
          end
        end

        resources :payments do
          collection do
            get :billing_addresses
            post :create_paypal_payment
            post :create_credit_payment
          end
        end

        resources :referrals, only: [:index] do
          collection do
            get :get_referral_bonus_amount
            get :get_content_for_referral
          end
        end
      end

      namespace :doctors do
        resources :doctors do 
          collection do 
            put :select_transportation_method
            get :get_infos
            put :update_location
            get :find_doctors_around
            put :update_working_status
            put :update_device_token
          end
        end

        resources :appointments, only: [:index, :show] do
          member do
            put :return_appointment
            put :delayed_appointment
            put :mark_appointment_started
            put :confirm_appointment
            put :confirm_on_way
            get :get_patient_phone
            post :create_invoice
          end
          collection do
            get :counted_by_months
            get :current
            get :next_appointments
            get :counted_in_month
            get :upcoming
          end
        end

        post 'sessions' => 'sessions#create'
        put 'passwords/forgot' => 'passwords#forgot'
        get 'charges' => 'charges#charges'
        get 'charges_with_appointment' => 'charges#charges_with_appointment'
      end

      resources :doctors do
        member do
          put :update_location
          get :get_current_location
        end
      end

      resources :directories
      resources :schedules do
        collection do
          get :load_default_schedules
          get :load_custom_calendars
          put :apply_default_schedule
          put :update_event
        end
      end

      resources :calendars do
        collection do
          get :load_default_schedules
          get :load_custom_calendars
          put :apply_default_schedule
          put :update_event
        end
      end

      resources :appointments do
        collection do
          get :fee
        end
      end

      resources :push_notifications, only: [] do
        collection do
          get :dispached_doctor
          get :appointment_complete
          get :doctor_on_way
          get :patient_cancellation
          get :dr_confirmed_appointment_started
        end
      end

      get 'vouchers/:voucher_code/validate' => "vouchers#validate", as: :validate_voucher_code
    end
  end
end
