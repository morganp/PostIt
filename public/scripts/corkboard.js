$(function() {

  //Note Functions
  function moveNoteToMode(note,mode) {
    note.
      remove(). //remove from old mode
      attr('style', ''). //remove offset
      insertBefore($('.note-placeholder', mode)). //insert into new mode
      draggable(); //make draggable again
  }

  function postNewNote(note, attributes) {
    $.post("/note/create", attributes, function(data) {
      note.attr('id', data);
    });
  }
  function postNoteUpdate(id, attributes) {
    $.post("/note/"+id, attributes);
  }

  function editNote(note) {
    if (!note.hasClass('editing')) {
      note.addClass('editing');

      var title = $('.title', note);
      var description = $('.description', note);
      var inp = $('<input type="text">').val(title.text().trim());
      var textArea = $('<textarea></textarea>').text(description.text().trim());
      
      var updateNote = function(e) {
        if (e.which === 13) {
          var new_title = inp.val().trim();
          var new_description = textArea.val().trim();
          var new_mode_name = note.closest('.mode').attr('id');

          var id = note.attr('id');
          var attributes = {
            title: new_title, 
            description: new_description,
            mode_name: new_mode_name
          };
          if (id) {
            postNoteUpdate(note.attr('id'), attributes);
          } else {
            postNewNote(note, attributes);
          }
          title.html(new_title);
          description.html(new_description);

          note.removeClass('editing');
        }
      };
      
      inp.keypress(updateNote);
      textArea.keypress(updateNote);

      title.html(inp);
      description.html(textArea);
    }
  }
  function addNote(mode) {
    var newNote = $('<div class="note"><div class="title"></div><div class="description"></div></div>');
    newNote.insertBefore($('.note-placeholder', mode));
    newNote.draggable();
    editNote(newNote);
  }

  $('.new-note').click(function() {
    addNote($(this).closest('.mode'));
    return false;
  });

  $('.note').live('dblclick', function() {
    editNote($(this));
  });

  //Board Functions
  function postNewBoard(board, attributes, callback) {
      //      console.log('postNewBoard ');
      //      console.log(board);
      //      console.log(attributes);
    
    $.post("/board/create", attributes, function(data) {
      board.attr('id', data);
      callback(data);
    });
  }

  function postBoardUpdate(id, attributes) {
    $.post("/board/"+id, attributes);
  }

  function editBoard(board) {
    if (!board.hasClass('editing')) {
      board.addClass('editing');

      var title = $('.title', board);
      //var description = $('.description', not);
      var inp = $('<input type="text">').val(title.text().trim());
      //var textArea = $('<textarea></textarea>').text(description.text().trim());
      
      var updateBoard = function(e) {
        if (e.which === 13) {
          var new_title = inp.val().trim();
          //var new_description = textArea.val().trim();
          //var new_mode_name = note.closest('.mode').attr('id');

          var id = board.attr('id');
          var attributes = {
            title: new_title 
            //description: new_description,
            //mode_name: new_mode_name
          };
          if (id) {
            postBoardUpdate(board.attr('id'), attributes);
          } else {
            postNewBoard(board, attributes, function(new_id) {
              title.html('<a href="/board/' + new_id + '">' + new_title + '</a>');
            });
          }

          //description.html(new_description);

          board.removeClass('editing');
        }
      };
      
      inp.keypress(updateBoard);
      //textArea.keypress(updateBoard);

      title.html(inp);
      //description.html(textArea);
    }
  }

  function addBoard() {
    var newBoard = $('<div class="board"><div class="title"></div></div>');
    newBoard.insertBefore($('.board-placeholder'));
    newBoard.draggable();
    editBoard(newBoard);
  }

  $('.new-board').click(function() {
    addBoard($(this)); //.closest('.mode'));
    return false;
  });

  $('.board').live('dblclick', function() {
    editBoard($(this));
  });

  // Drag drop functions
  $( ".draggable" ).draggable();
  $( ".droppable" ).droppable({
    hoverClass: 'hovered',
    drop: function( event, ui ) {
      var mode    = $(this);
      var mode_id = mode.attr('id');
      var note    = ui.draggable;
      moveNoteToMode(note, this);
      //Send Post request, sinatra handles this to update
      postNoteUpdate(note.attr('id'), {mode_name: mode_id});
    }
  });

});
