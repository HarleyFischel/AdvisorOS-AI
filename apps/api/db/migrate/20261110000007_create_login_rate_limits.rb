class CreateLoginRateLimits < ActiveRecord::Migration[7.2]
  def change
    create_table :login_rate_limits, id: :uuid do |t|
      t.string :key, null: false
      t.datetime :window_started_at, null: false
      t.integer :attempts, null: false, default: 0
      t.timestamps
    end
    add_index :login_rate_limits, :key, unique: true
    add_check_constraint :login_rate_limits, "attempts >= 0", name: "login_rate_limits_attempts_nonnegative"
  end
end
