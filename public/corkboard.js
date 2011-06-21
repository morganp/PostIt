$(function() {
  function moveNoteToMode(note,mode) {
    note.
      remove(). //remove from old mode
      attr('style', ''). //remove offset
      insertBefore($('.note-placeholder', mode)). //insert into new mode
      draggable(); //make draggable again
  }

  function postNoteUpdate(id, attributes) {
    $.post("note/"+id, attributes);
  }

  $('.note').dblclick(function() {
    var note = $(this);
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

          postNoteUpdate(note.attr('id'), {
            title: new_title, 
            description: new_description
          });

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
  });


  $( ".draggable" ).draggable();
  $( ".droppable" ).droppable({
    hoverClass: 'hovered',
    drop: function( event, ui ) {
      var mode = $(this);
      var mode_id = mode.attr('id');
      var note = ui.draggable;
      moveNoteToMode(note, this);
      //Send Post request, sinatra handles this to update
      postNoteUpdate(note.attr('id'), {mode_name: mode_id});
    }
  });

});
