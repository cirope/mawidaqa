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

ActiveRecord::Schema.define(version: 20130213194840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "changes", force: true do |t|
    t.text     "content",                  null: false
    t.date     "made_at",                  null: false
    t.integer  "lock_version", default: 0, null: false
    t.integer  "document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "changes", ["document_id"], name: "index_changes_on_document_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "content",                      null: false
    t.integer  "lock_version",     default: 0, null: false
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree

  create_table "documents", force: true do |t|
    t.string   "name",                                  null: false
    t.string   "code",                                  null: false
    t.string   "status",                                null: false
    t.string   "version",                               null: false
    t.text     "notes"
    t.text     "version_comments"
    t.boolean  "current",          default: false,      null: false
    t.integer  "lock_version",     default: 0,          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.text     "xml_reference"
    t.text     "revision_url"
    t.integer  "organization_id",                       null: false
    t.string   "kind",             default: "document", null: false
  end

  add_index "documents", ["code"], name: "index_documents_on_code", using: :btree
  add_index "documents", ["current"], name: "index_documents_on_current", using: :btree
  add_index "documents", ["name"], name: "index_documents_on_name", using: :btree
  add_index "documents", ["organization_id"], name: "index_documents_on_organization_id", using: :btree
  add_index "documents", ["parent_id"], name: "index_documents_on_parent_id", using: :btree
  add_index "documents", ["status"], name: "index_documents_on_status", using: :btree

  create_table "documents_tags", id: false, force: true do |t|
    t.integer "document_id", null: false
    t.integer "tag_id",      null: false
  end

  add_index "documents_tags", ["document_id", "tag_id"], name: "index_documents_tags_on_document_id_and_tag_id", unique: true, using: :btree

  create_table "jobs", force: true do |t|
    t.string   "job",                         null: false
    t.integer  "lock_version",    default: 0, null: false
    t.integer  "user_id",                     null: false
    t.integer  "organization_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["organization_id"], name: "index_jobs_on_organization_id", using: :btree
  add_index "jobs", ["user_id"], name: "index_jobs_on_user_id", using: :btree

  create_table "logins", force: true do |t|
    t.string   "ip",         null: false
    t.text     "user_agent"
    t.datetime "created_at", null: false
    t.integer  "user_id",    null: false
  end

  add_index "logins", ["user_id"], name: "index_logins_on_user_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name",                       null: false
    t.string   "identification"
    t.text     "xml_reference"
    t.integer  "lock_version",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["identification"], name: "index_organizations_on_identification", unique: true, using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name",                        null: false
    t.integer  "lock_version",    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "organization_id",             null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["organization_id"], name: "index_tags_on_organization_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                                null: false
    t.string   "lastname"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "roles_mask",             default: 0,  null: false
    t.integer  "lock_version",           default: 0,  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["lastname"], name: "index_users_on_lastname", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.integer  "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  add_index "versions", ["whodunnit"], name: "index_versions_on_whodunnit", using: :btree

end
