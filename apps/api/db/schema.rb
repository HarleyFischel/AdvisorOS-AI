# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_11_09_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "client_id", null: false
    t.uuid "user_id", null: false
    t.string "activity_type", default: "note", null: false
    t.text "summary", null: false
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_activities_on_client_id"
    t.index ["organization_id", "occurred_at"], name: "index_activities_on_organization_id_and_occurred_at"
    t.index ["organization_id"], name: "index_activities_on_organization_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
    t.check_constraint "activity_type::text = ANY (ARRAY['note'::character varying, 'call'::character varying, 'email'::character varying, 'meeting'::character varying, 'task'::character varying]::text[])", name: "activities_type_valid"
  end

  create_table "audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "actor_user_id", null: false
    t.string "action", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.index ["actor_user_id"], name: "index_audit_events_on_actor_user_id"
    t.index ["organization_id", "created_at"], name: "index_audit_events_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_audit_events_on_organization_id"
    t.index ["record_type", "record_id"], name: "index_audit_events_on_record_type_and_record_id"
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "household_id"
    t.uuid "assigned_user_id"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "phone"
    t.string "status", default: "prospect", null: false
    t.decimal "estimated_aum", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_clients_on_assigned_user_id"
    t.index ["household_id"], name: "index_clients_on_household_id"
    t.index ["organization_id", "last_name", "first_name"], name: "index_clients_on_organization_id_and_last_name_and_first_name"
    t.index ["organization_id", "status"], name: "index_clients_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_clients_on_organization_id"
    t.check_constraint "estimated_aum >= 0::numeric", name: "clients_aum_nonnegative"
    t.check_constraint "status::text = ANY (ARRAY['prospect'::character varying, 'active'::character varying, 'inactive'::character varying]::text[])", name: "clients_status_valid"
  end

  create_table "households", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "name"], name: "index_households_on_organization_id_and_name"
    t.index ["organization_id"], name: "index_households_on_organization_id"
  end

  create_table "opportunities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.uuid "client_id", null: false
    t.uuid "owner_user_id", null: false
    t.string "title", null: false
    t.string "stage", default: "lead", null: false
    t.decimal "estimated_value", precision: 15, scale: 2, default: "0.0", null: false
    t.date "expected_close_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_opportunities_on_client_id"
    t.index ["organization_id", "stage"], name: "index_opportunities_on_organization_id_and_stage"
    t.index ["organization_id"], name: "index_opportunities_on_organization_id"
    t.index ["owner_user_id"], name: "index_opportunities_on_owner_user_id"
    t.check_constraint "estimated_value >= 0::numeric", name: "opportunities_value_nonnegative"
    t.check_constraint "stage::text = ANY (ARRAY['lead'::character varying, 'qualified'::character varying, 'proposal'::character varying, 'negotiation'::character varying, 'won'::character varying, 'lost'::character varying]::text[])", name: "opportunities_stage_valid"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "organization_id", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.string "role", default: "viewer", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying, 'advisor'::character varying, 'viewer'::character varying]::text[])", name: "users_role_valid"
  end

  add_foreign_key "activities", "clients"
  add_foreign_key "activities", "organizations"
  add_foreign_key "activities", "users"
  add_foreign_key "audit_events", "organizations"
  add_foreign_key "audit_events", "users", column: "actor_user_id"
  add_foreign_key "clients", "households"
  add_foreign_key "clients", "organizations"
  add_foreign_key "clients", "users", column: "assigned_user_id"
  add_foreign_key "households", "organizations"
  add_foreign_key "opportunities", "clients"
  add_foreign_key "opportunities", "organizations"
  add_foreign_key "opportunities", "users", column: "owner_user_id"
  add_foreign_key "users", "organizations"
end
