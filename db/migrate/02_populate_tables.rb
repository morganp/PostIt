class User < ActiveRecord::Base
  has_many :notes
  has_many :modes
  has_many :colours
  has_many :boards
end

class Mode < ActiveRecord::Base
  belongs_to :user
  belongs_to :board
  has_many :notes
end

class Colour < ActiveRecord::Base
  belongs_to :user
  has_many :notes
end

class Note < ActiveRecord::Base
  belongs_to :user
  belongs_to :mode
  belongs_to :colour
  belongs_to :board
end

class Board < ActiveRecord::Base
  belongs_to :user
end

class PopulateTables < ActiveRecord::Migration
  def self.up
    @user = User.create(
      :name => 'Morgan',
      :email => 'morgan.prior@gmail.com',
      :auth  => 'xyz'
    )

    @user.boards.create(
      :title => 'Mainboard',
      :read_security => 1,
      :write_security => 1,
      :layout => '[3]'
    )

    @icebox = @user.modes.create(      :title => 'IceBox', :board_id => @user.boards.first.id  )
    @todo   = @user.modes.create(      :title => 'ToDo',   :board_id => @user.boards.first.id  )
    @done   = @user.modes.create(      :title => 'Done',   :board_id => @user.boards.first.id  )
    
    @colour = @user.colours.create(
      :background => '#EDACF0',
      :foreground => '#FFFFFF'
    )

    @icebox.notes.create(
      :title => 'First Note',
      :description => 'example note',
      :colour_id => @user.modes.first.id
      
    )

    @icebox.notes.create(
      :title => 'Second Note',
      :description => 'example note',
      :colour_id => @user.modes.first.id
    )

    @todo.notes.create(
      :title => 'Third Note',
      :description => 'example note',
      :colour_id => @user.modes.first.id
    )
    @todo.notes.create(
      :title => 'Fourth Note',
      :description => 'example note',
      :colour_id => @user.modes.first.id
    )


    @user.save

  end

  def self.down
     
    Note.delete_all
    #@notes.each do |note|
    #  note.delete
    #end

    Mode.delete_all
    Colour.delete_all
    User.delete_all
  end
end
