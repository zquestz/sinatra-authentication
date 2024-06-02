unless (ActiveRecord::Base.connection.table_exists?("ar_users") rescue true)
  class CreateArUsers < ActiveRecord::Migration
    def self.up
      create_table :ar_users do |t|
        t.string :email
        t.string :hashed_password
        t.string :salt
        t.integer :permission_level
        t.string :fb_uid

        t.timestamps
      end

      add_index :ar_users, :email, :unique => true
    end

    def self.down
      remove_index :ar_users, :email
      drop_table :ar_users
    end
  end

  CreateArUsers.up
end

class ArUser < ActiveRecord::Base
  attr_accessor :password, :password_confirmation

  validates_format_of :email, :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i
  validates_uniqueness_of :email

  validates :password, :presence => true, :confirmation => true, :length => {:within => 8..40}, :on => :create
  validates :password, :allow_blank => true, :confirmation => true, :length => {:within => 8..40}, :on => :update

  def password=(pass)
    @password = pass
    self.salt = User.random_string(10)
    self.hashed_password = User.encrypt(@password, self.salt)
  end

  def admin?
    self.permission_level == -1 || self.id == 1
  end

  def site_admin?
    self.id == 1
  end

  def to_ary
    self.attributes.values
  end
end
