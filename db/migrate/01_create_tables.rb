
class CreateTables < ActiveRecord::Migration
  def self.up
    create_table "notes", :force => true do |t|
      t.belongs_to  :user
      t.belongs_to  :mode 
      t.belongs_to  :colour
      t.belongs_to  :board
      t.string   "title"
      t.text     "description"

      t.timestamps
    end

    create_table "users", :force => true do |t|
      #t.has_many :notes
      #t.has_many :modes
      #t.has_many :colour
      t.string "name"
      t.string "email"
      t.string "auth"

      t.timestamps
    end

    create_table "modes", :force => true do |t|
      t.belongs_to :user
      t.belongs_to :board
      t.string "title"

      t.timestamps
    end

    create_table "colours", :force => true do |t|
      t.belongs_to :user
      t.string "background"
      t.string "foreground"

      t.timestamps
    end

    create_table "boards", :force => true do |t|
      t.belongs_to :user

      t.string  "title"
      t.integer "read_security"
      t.integer "write_security"
      t.string  "layout"

      t.timestamps
    end


  end

  def self.down
    drop_table :notes
    drop_table :users
    drop_table :modes
    drop_table :colours
    drop_table :boards
  end
end
