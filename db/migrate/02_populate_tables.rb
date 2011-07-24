
  def gen_board_key
    o    = [(1..9),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    key  = (0...8).map{ o[rand(o.length)]  }.join;
    
    #No items found then the key is safe to use
    unique = Board.find_by_alphakey( key )
    if unique.nil?
      return key
    else
      return gen_board_key 
    end
  end

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
  has_many :modes
end

class PopulateTables < ActiveRecord::Migration
  def self.up
    @user = User.create(
      :name => 'Morgan',
      :email => 'morgan.prior@gmail.com',
      :auth  => 'xyz'
    )

    @board = @user.boards.create(
      :alphakey => gen_board_key,
      :title => 'Mainboard',
      :read_security => 1,
      :write_security => 1,
      :layout => '[3]'
    )

    @icebox = @board.modes.create(      :title => 'IceBox', :board_id => @user.boards.first.id  )
    @todo   = @board.modes.create(      :title => 'ToDo',   :board_id => @user.boards.first.id  )
    @done   = @board.modes.create(      :title => 'Done',   :board_id => @user.boards.first.id  )
    
    @colour = @user.colours.create(
      :background => '#EDACF0',
      :foreground => '#FFFFFF'
    )

    @icebox.notes.create(
      :title => 'First Note',
      :description => 'example note',
      :colour_id => Colour.first.id, 
      :board_id => @icebox.board_id,
      :user_id => @user.id

    )

    @icebox.notes.create(
      :title => 'Second Note',
      :description => 'example note',
      :colour_id => Colour.first.id, 
      :board_id => @icebox.board_id,
      :user_id => @user.id
    )

    @todo.notes.create(
      :title => 'Third Note',
      :description => 'example note',
      :colour_id => Colour.first.id, 
      :board_id => @icebox.board_id,
      :user_id => @user.id

    )
    @todo.notes.create(
      :title => 'Fourth Note',
      :description => 'example note',
      :colour_id => Colour.first.id, 
      :board_id => @icebox.board_id,
      :user_id => @user.id

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
