# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151021101041) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "about_us_questions", force: :cascade do |t|
    t.string   "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "agencies", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "name"
    t.string   "address"
    t.string   "phone_number"
    t.string   "account_number"
    t.string   "bank_name"
    t.string   "branch_address"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                 default: 0
    t.string   "sort_code"
    t.text     "reason"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role"
    t.integer  "gender"
    t.string   "company_name"
    t.string   "auth_token"
    t.string   "answer_about_us"
  end

  add_index "agencies", ["email"], name: "index_agencies_on_email", unique: true, using: :btree
  add_index "agencies", ["reset_password_token"], name: "index_agencies_on_reset_password_token", unique: true, using: :btree

  create_table "agency_periods", force: :cascade do |t|
    t.integer  "agency_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "default_common_status"
    t.integer  "default_specific_status"
    t.integer  "custom_status"
    t.string   "changed_by"
    t.integer  "period_id"
    t.integer  "doctor_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "week_day"
    t.string   "starttime_at"
    t.string   "endtime_at"
    t.boolean  "is_apply_default_to_custom"
    t.boolean  "is_default_week"
  end

  add_index "agency_periods", ["agency_id"], name: "index_agency_periods_on_agency_id", using: :btree
  add_index "agency_periods", ["doctor_id"], name: "index_agency_periods_on_doctor_id", using: :btree
  add_index "agency_periods", ["period_id"], name: "index_agency_periods_on_period_id", using: :btree

  create_table "apply_schedules", force: :cascade do |t|
    t.boolean  "is_apply"
    t.datetime "on_date"
    t.integer  "doctor_id"
    t.integer  "agency_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "week_day"
    t.boolean  "is_apply_week", default: false
    t.boolean  "is_apply_day"
  end

  add_index "apply_schedules", ["agency_id"], name: "index_apply_schedules_on_agency_id", using: :btree
  add_index "apply_schedules", ["doctor_id"], name: "index_apply_schedules_on_doctor_id", using: :btree

  create_table "appointment_events", force: :cascade do |t|
    t.integer  "appointment_id",                                                  null: false
    t.integer  "event_id",                                                        null: false
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.string   "sms_message"
    t.string   "notification_message"
    t.decimal  "base_cost",              precision: 10, scale: 2
    t.decimal  "vat",                    precision: 10, scale: 2
    t.decimal  "doctor_credit",          precision: 10, scale: 2
    t.decimal  "doctor_fine",            precision: 10, scale: 2
    t.decimal  "patient_credit",         precision: 10, scale: 2
    t.decimal  "patient_fee",            precision: 10, scale: 2
    t.decimal  "gpdq_income",            precision: 10, scale: 2
    t.decimal  "gpdq_cost",              precision: 10, scale: 2
    t.integer  "reason_code_id"
    t.boolean  "standard"
    t.text     "free_text"
    t.boolean  "created_manual"
    t.integer  "patient_id"
    t.integer  "doctor_id"
    t.boolean  "is_processed",                                    default: true
    t.boolean  "require_manual_process",                          default: false
  end

  add_index "appointment_events", ["appointment_id", "event_id"], name: "index_appointment_events_on_appointment_id_and_event_id", using: :btree
  add_index "appointment_events", ["appointment_id", "is_processed"], name: "index_appointment_events_on_appointment_id_and_is_processed", using: :btree
  add_index "appointment_events", ["appointment_id"], name: "index_appointment_events_on_appointment_id", using: :btree
  add_index "appointment_events", ["doctor_id"], name: "index_appointment_events_on_doctor_id", using: :btree
  add_index "appointment_events", ["patient_id"], name: "index_appointment_events_on_patient_id", using: :btree
  add_index "appointment_events", ["reason_code_id"], name: "index_appointment_events_on_reason_code_id", using: :btree

  create_table "appointment_fees", force: :cascade do |t|
    t.integer  "appointment_id"
    t.decimal  "price_per_unit", precision: 10, scale: 2
    t.integer  "quantity"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "price_item_id"
  end

  add_index "appointment_fees", ["price_item_id"], name: "index_appointment_fees_on_price_item_id", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.integer  "doctor_id"
    t.integer  "patient_id"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "duration"
    t.string   "description"
    t.integer  "status",                                            default: 0
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.integer  "apm_type",                                          default: 0
    t.integer  "agency_id"
    t.integer  "rating"
    t.text     "feedback"
    t.integer  "is_canceled",                                       default: 0
    t.integer  "payment_status"
    t.datetime "assigned_time_at"
    t.integer  "booking_type",                                      default: 0
    t.datetime "confirmed_on_way_at"
    t.integer  "voucher_id"
    t.boolean  "is_referred",                                       default: false
    t.integer  "rating_manner",                                     default: 0
    t.integer  "paymentable_id"
    t.string   "paymentable_type"
    t.decimal  "lat",                      precision: 12, scale: 8
    t.decimal  "lng",                      precision: 12, scale: 8
    t.string   "address"
    t.decimal  "lat_bill_address",         precision: 12, scale: 8
    t.decimal  "lng_bill_address",         precision: 12, scale: 8
    t.string   "bill_address"
    t.integer  "canceled_by_id"
    t.string   "canceled_by_type"
    t.text     "comment"
    t.datetime "est_end_at"
    t.decimal  "appointment_fee",          precision: 10, scale: 2
    t.integer  "delayed_time",                                      default: 0
    t.datetime "confirmed_appointment_at"
    t.datetime "update_start_at"
    t.string   "transport",                                         default: "transit"
  end

  add_index "appointments", ["agency_id"], name: "index_appointments_on_agency_id", using: :btree
  add_index "appointments", ["doctor_id"], name: "index_appointments_on_doctor_id", using: :btree
  add_index "appointments", ["patient_id"], name: "index_appointments_on_patient_id", using: :btree
  add_index "appointments", ["voucher_id"], name: "index_appointments_on_voucher_id", using: :btree

  create_table "bank_holidays", force: :cascade do |t|
    t.date     "event_date"
    t.string   "event_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "title"
    t.integer  "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "credits", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "appointment_id"
    t.integer  "patient_reference_id"
    t.decimal  "credit_number",        precision: 8, scale: 2
    t.datetime "expired_date"
    t.boolean  "is_used",                                      default: false
    t.integer  "credit_type"
    t.datetime "used_at"
    t.integer  "used_appointment_id"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
  end

  add_index "credits", ["patient_id"], name: "index_credits_on_patient_id", using: :btree

  create_table "custom_schedules", force: :cascade do |t|
    t.integer  "schedule_id"
    t.datetime "working_date"
    t.integer  "week_day"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "doctor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "custom_schedules", ["doctor_id"], name: "index_custom_schedules_on_doctor_id", using: :btree
  add_index "custom_schedules", ["schedule_id"], name: "index_custom_schedules_on_schedule_id", using: :btree

  create_table "doctor_return_appointments", force: :cascade do |t|
    t.integer  "doctor_id"
    t.integer  "appointment_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "doctor_zones", force: :cascade do |t|
    t.integer  "doctor_id"
    t.integer  "zone_id"
    t.integer  "eta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "doctor_zones", ["doctor_id"], name: "index_doctor_zones_on_doctor_id", using: :btree
  add_index "doctor_zones", ["zone_id"], name: "index_doctor_zones_on_zone_id", using: :btree

  create_table "doctors", force: :cascade do |t|
    t.string   "email",                                                default: "",    null: false
    t.string   "encrypted_password",                                   default: "",    null: false
    t.string   "name"
    t.string   "phone_number"
    t.string   "phone_landline"
    t.string   "avatar"
    t.string   "gmc_cert"
    t.string   "dbs_cert"
    t.string   "mdu_mps_cert"
    t.string   "passport"
    t.string   "default_start_location"
    t.string   "last_appraisal_summary"
    t.string   "reference_gp"
    t.string   "hepatitis_b_status"
    t.string   "child_protection_cert"
    t.string   "adult_safeguarding_cert"
    t.integer  "status",                                               default: 0
    t.integer  "agency_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                        default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "gmc_cert_exp"
    t.date     "dbs_cert_exp"
    t.date     "mdu_mps_cert_exp"
    t.date     "last_appraisal_summary_exp"
    t.date     "reference_gp_exp"
    t.date     "hepatitis_b_status_exp"
    t.date     "child_protection_cert_exp"
    t.date     "adult_safeguarding_cert_exp"
    t.decimal  "latitude",                    precision: 12, scale: 8
    t.decimal  "longitude",                   precision: 12, scale: 8
    t.boolean  "available",                                            default: false
    t.text     "reason"
    t.datetime "last_schedule_update"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "role"
    t.integer  "gender"
    t.string   "company_name"
    t.string   "auth_token"
    t.text     "description"
    t.boolean  "is_hold",                                              default: false
    t.string   "transportation"
    t.boolean  "is_transit",                                           default: false
    t.string   "answer_about_us"
    t.string   "address"
    t.text     "device_token"
    t.string   "platform"
  end

  add_index "doctors", ["email"], name: "index_doctors_on_email", unique: true, using: :btree
  add_index "doctors", ["reset_password_token"], name: "index_doctors_on_reset_password_token", unique: true, using: :btree

  create_table "elements", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "address"
    t.datetime "open_at"
    t.datetime "close_at"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "event_categories", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "event_messages", force: :cascade do |t|
    t.integer  "event_id"
    t.integer  "reason_code_id"
    t.string   "doctor_sms"
    t.string   "doctor_push"
    t.string   "patient_sms"
    t.string   "patient_push"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "doctor_push_in_app"
    t.string   "patient_push_in_app"
  end

  add_index "event_messages", ["event_id", "reason_code_id"], name: "index_event_messages_on_event_id_and_reason_code_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",                 null: false
    t.boolean  "standard",             null: false
    t.boolean  "created_via_back_end"
    t.boolean  "created_via_app"
    t.boolean  "doctor_sms"
    t.boolean  "doctor_push"
    t.boolean  "patient_sms"
    t.boolean  "patient_push"
    t.boolean  "in_app_alert"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "event_category_id"
    t.string   "name_for_push"
    t.string   "static_name"
  end

  add_index "events", ["event_category_id"], name: "index_events_on_event_category_id", using: :btree
  add_index "events", ["name"], name: "index_events_on_name", unique: true, using: :btree
  add_index "events", ["standard"], name: "index_events_on_standard", using: :btree
  add_index "events", ["static_name"], name: "index_events_on_static_name", using: :btree

  create_table "extra_fees", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price",      precision: 10, scale: 2
    t.string   "extra_type"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "faq_doctors", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.boolean  "is_published", default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "google_distance_records", force: :cascade do |t|
    t.string   "origin"
    t.string   "destination"
    t.string   "transportation"
    t.float    "duration"
    t.float    "distance"
    t.boolean  "no_result",      default: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "gpdq_emails", force: :cascade do |t|
    t.string   "department"
    t.string   "email"
    t.boolean  "is_published", default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "gpdq_phones", force: :cascade do |t|
    t.string   "department"
    t.string   "phone_number"
    t.boolean  "is_published", default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "gpdq_settings", force: :cascade do |t|
    t.string   "name"
    t.decimal  "value",      precision: 10, scale: 2
    t.integer  "time_unit"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "helps", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_published", default: false
  end

  create_table "invoices", force: :cascade do |t|
    t.decimal  "total_prices",   precision: 10, scale: 2
    t.integer  "appointment_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.integer  "status",                                  default: 0
    t.decimal  "total_extra",    precision: 10, scale: 2, default: 0.0
    t.decimal  "vat",            precision: 10, scale: 2
    t.decimal  "discount",       precision: 10, scale: 2, default: 0.0
  end

  create_table "items_invoices", force: :cascade do |t|
    t.integer "price_item_id"
    t.integer "invoice_id"
    t.decimal "item_price",    precision: 10, scale: 2
    t.integer "quantity",                               default: 1
  end

  add_index "items_invoices", ["invoice_id"], name: "index_items_invoices_on_invoice_id", using: :btree
  add_index "items_invoices", ["price_item_id"], name: "index_items_invoices_on_price_item_id", using: :btree

  create_table "judo_transactions", force: :cascade do |t|
    t.integer  "appointment_id"
    t.integer  "payment_type"
    t.integer  "status"
    t.string   "amount"
    t.string   "consumer_token"
    t.string   "your_consumer_reference"
    t.string   "currency"
    t.string   "net_amount"
    t.string   "receipt_id"
    t.string   "your_payment_reference"
    t.string   "card_type"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string   "address"
    t.boolean  "is_current"
    t.integer  "patient_id"
    t.decimal  "latitude",           precision: 12, scale: 8
    t.decimal  "longitude",          precision: 12, scale: 8
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.boolean  "is_current_billing",                          default: false
    t.boolean  "is_bill_address",                             default: false
    t.integer  "address_type"
  end

  add_index "locations", ["patient_id"], name: "index_locations_on_patient_id", using: :btree

  create_table "manual_process_events", force: :cascade do |t|
    t.integer  "event_id",                      null: false
    t.integer  "reason_code_id"
    t.boolean  "manual_process", default: true
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "manual_process_events", ["event_id", "reason_code_id"], name: "index_manual_process_events_on_event_id_and_reason_code_id", unique: true, using: :btree

  create_table "out_coverage_areas", force: :cascade do |t|
    t.string   "patient_name"
    t.string   "patient_email"
    t.string   "post_code"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "patient_credit_payments", force: :cascade do |t|
    t.string   "cc_num"
    t.string   "expiry"
    t.string   "cvc"
    t.integer  "cc_type"
    t.string   "billing_address"
    t.integer  "patient_id"
    t.integer  "appointment_id"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.boolean  "is_active",                                 default: true
    t.decimal  "lat_bill_address", precision: 12, scale: 8
    t.decimal  "lng_bill_address", precision: 12, scale: 8
    t.string   "bill_address"
  end

  add_index "patient_credit_payments", ["appointment_id"], name: "index_patient_credit_payments_on_appointment_id", using: :btree
  add_index "patient_credit_payments", ["is_active"], name: "index_patient_credit_payments_on_is_active", using: :btree
  add_index "patient_credit_payments", ["patient_id"], name: "index_patient_credit_payments_on_patient_id", using: :btree

  create_table "patient_doctors", force: :cascade do |t|
    t.integer  "patient_id"
    t.integer  "doctor_id"
    t.float    "eta"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "km"
    t.string   "transport"
  end

  add_index "patient_doctors", ["doctor_id"], name: "index_patient_doctors_on_doctor_id", using: :btree
  add_index "patient_doctors", ["patient_id"], name: "index_patient_doctors_on_patient_id", using: :btree

  create_table "patient_hold_doctors", force: :cascade do |t|
    t.integer  "doctor_id"
    t.datetime "hold_at"
    t.datetime "release_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "patientable_id"
    t.string   "patientable_type"
  end

  add_index "patient_hold_doctors", ["doctor_id"], name: "index_patient_hold_doctors_on_doctor_id", using: :btree
  add_index "patient_hold_doctors", ["patientable_id"], name: "index_patient_hold_doctors_on_patientable_id", using: :btree

  create_table "patient_paypal_payments", force: :cascade do |t|
    t.string   "paypal_email"
    t.string   "password"
    t.integer  "patient_id"
    t.integer  "appointment_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "password_hash"
    t.integer  "location_id"
    t.string   "paypal_access_token"
    t.string   "refresh_token"
  end

  add_index "patient_paypal_payments", ["appointment_id"], name: "index_patient_paypal_payments_on_appointment_id", using: :btree
  add_index "patient_paypal_payments", ["location_id"], name: "index_patient_paypal_payments_on_location_id", using: :btree
  add_index "patient_paypal_payments", ["patient_id"], name: "index_patient_paypal_payments_on_patient_id", using: :btree

  create_table "patients", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "first_name"
    t.string   "last_name"
    t.text     "fb_id"
    t.text     "device_token"
    t.string   "avatar"
    t.text     "fb_token"
    t.text     "auth_token"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.integer  "zone_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "phone_number"
    t.string   "account_number"
    t.string   "bank_name"
    t.string   "branch_address"
    t.string   "sort_code"
    t.integer  "status",                 default: 0
    t.string   "provider"
    t.string   "uid"
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "fullname"
    t.datetime "changed_at"
    t.integer  "referred_by"
    t.boolean  "got_first_booking",      default: false
    t.string   "platform"
    t.string   "paypal_access_token"
  end

  add_index "patients", ["email"], name: "index_patients_on_email", unique: true, using: :btree
  add_index "patients", ["referred_by"], name: "index_patients_on_referred_by", using: :btree
  add_index "patients", ["reset_password_token"], name: "index_patients_on_reset_password_token", unique: true, using: :btree

  create_table "paypal_transactions", force: :cascade do |t|
    t.integer  "appointment_id"
    t.integer  "status"
    t.decimal  "amount",           precision: 10, scale: 2
    t.string   "payment_id"
    t.string   "currency",                                  default: "GBP"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.string   "description"
    t.string   "authorization_id"
    t.integer  "payment_type"
  end

  add_index "paypal_transactions", ["appointment_id"], name: "index_paypal_transactions_on_appointment_id", using: :btree

  create_table "periods", force: :cascade do |t|
    t.integer  "schedule_id"
    t.integer  "agency_status"
    t.integer  "duration"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "doctor_status"
    t.integer  "appointment_id"
    t.integer  "custom_schedule_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "periods", ["appointment_id"], name: "index_periods_on_appointment_id", using: :btree
  add_index "periods", ["custom_schedule_id"], name: "index_periods_on_custom_schedule_id", using: :btree
  add_index "periods", ["schedule_id"], name: "index_periods_on_schedule_id", using: :btree

  create_table "price_categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "allow_expand",         default: true
    t.boolean  "allow_edit_price",     default: false
    t.boolean  "allow_patient_expand", default: false
    t.string   "cat_type"
    t.integer  "category_order"
    t.boolean  "allow_doctor_view",    default: true
  end

  create_table "price_items", force: :cascade do |t|
    t.string   "name"
    t.decimal  "price_per_unit",   precision: 10, scale: 2
    t.string   "description"
    t.integer  "category_id"
    t.boolean  "is_default",                                default: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
    t.integer  "quantity",                                  default: 1
    t.datetime "deleted_at"
    t.boolean  "allow_doctor_add",                          default: true
    t.string   "price_type"
    t.boolean  "editable",                                  default: true
  end

  add_index "price_items", ["deleted_at"], name: "index_price_items_on_deleted_at", using: :btree

  create_table "price_lists", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "price",        precision: 10, scale: 2
    t.string   "price_type"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.boolean  "is_published",                          default: true
    t.integer  "order"
  end

  create_table "push_machines", force: :cascade do |t|
    t.integer  "appointment_id"
    t.integer  "event_id"
    t.integer  "receiver_id"
    t.integer  "receiver_role"
    t.string   "message"
    t.string   "app_message"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "push_machines", ["appointment_id"], name: "index_push_machines_on_appointment_id", using: :btree
  add_index "push_machines", ["event_id"], name: "index_push_machines_on_event_id", using: :btree
  add_index "push_machines", ["receiver_role"], name: "index_push_machines_on_receiver_role", using: :btree

  create_table "reason_codes", force: :cascade do |t|
    t.string   "name",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "static_name"
  end

  add_index "reason_codes", ["static_name"], name: "index_reason_codes_on_static_name", using: :btree

  create_table "referral_infos", force: :cascade do |t|
    t.integer  "referral_id"
    t.integer  "referred_user_id"
    t.decimal  "refer_amount"
    t.boolean  "was_bonused",      default: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "referral_infos", ["referral_id"], name: "index_referral_infos_on_referral_id", using: :btree
  add_index "referral_infos", ["referred_user_id"], name: "index_referral_infos_on_referred_user_id", using: :btree

  create_table "referral_settings", force: :cascade do |t|
    t.text     "sms"
    t.text     "email"
    t.text     "facebook"
    t.text     "twitter"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "email_subject", default: "Referral email from GPDQ"
  end

  create_table "schedules", force: :cascade do |t|
    t.datetime "working_date"
    t.integer  "agency_id"
    t.integer  "week_day"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "schedules", ["agency_id"], name: "index_schedules_on_agency_id", using: :btree

  create_table "sms_systems", force: :cascade do |t|
    t.integer  "doctor_id"
    t.integer  "patient_id"
    t.string   "to"
    t.string   "originator"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "status"
    t.string   "reason"
    t.integer  "sent_via"
    t.integer  "event_id"
  end

  add_index "sms_systems", ["event_id"], name: "index_sms_systems_on_event_id", using: :btree

  create_table "sub_zones", force: :cascade do |t|
    t.integer  "zone_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "temp_patients", force: :cascade do |t|
    t.string   "session_value"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.integer  "zone_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "changed_at"
  end

  create_table "terms_conditions", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vouchers", force: :cascade do |t|
    t.string   "voucher_code"
    t.decimal  "amount",         precision: 10, scale: 2
    t.boolean  "is_used",                                 default: false
    t.integer  "appointment_id"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "type",                                    default: "PromoCode", null: false
    t.text     "description"
    t.boolean  "is_percentage",                           default: false
    t.datetime "started_date"
    t.datetime "ended_date"
    t.integer  "sponsor_id"
  end

  add_index "vouchers", ["appointment_id"], name: "index_vouchers_on_appointment_id", using: :btree

  create_table "working_days", force: :cascade do |t|
    t.datetime "close_at"
    t.datetime "open_at"
    t.integer  "element_id"
    t.integer  "week_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "working_days", ["element_id"], name: "index_working_days_on_element_id", using: :btree

  create_table "zones", force: :cascade do |t|
    t.string   "name"
    t.string   "lat"
    t.string   "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "address"
  end

  add_foreign_key "agency_periods", "agencies"
  add_foreign_key "agency_periods", "doctors"
  add_foreign_key "agency_periods", "periods"
  add_foreign_key "apply_schedules", "agencies"
  add_foreign_key "apply_schedules", "doctors"
  add_foreign_key "appointments", "agencies"
  add_foreign_key "appointments", "doctors"
  add_foreign_key "appointments", "patients"
  add_foreign_key "credits", "patients"
  add_foreign_key "custom_schedules", "doctors"
  add_foreign_key "custom_schedules", "schedules"
  add_foreign_key "doctor_zones", "doctors"
  add_foreign_key "doctor_zones", "zones"
  add_foreign_key "items_invoices", "invoices"
  add_foreign_key "items_invoices", "price_items"
  add_foreign_key "locations", "patients"
  add_foreign_key "patient_credit_payments", "appointments"
  add_foreign_key "patient_credit_payments", "patients"
  add_foreign_key "patient_doctors", "doctors"
  add_foreign_key "patient_doctors", "patients"
  add_foreign_key "patient_hold_doctors", "doctors"
  add_foreign_key "patient_paypal_payments", "appointments"
  add_foreign_key "patient_paypal_payments", "patients"
  add_foreign_key "periods", "appointments"
  add_foreign_key "periods", "custom_schedules"
  add_foreign_key "periods", "schedules"
  add_foreign_key "schedules", "agencies"
  add_foreign_key "vouchers", "appointments"
  add_foreign_key "working_days", "elements"
end
