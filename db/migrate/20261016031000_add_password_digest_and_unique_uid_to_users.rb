class AddPasswordDigestAndUniqueUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :password_digest, :string
    add_index :users, :uid, unique: true
  end
end
