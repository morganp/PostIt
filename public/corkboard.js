$(function() {
  function moveNoteToMode(note,mode) {
    note.
      remove(). //remove from old mode
      attr('style', ''). //remove offset
      insertBefore($('.note-placeholder', mode)). //insert into new mode
      draggable(); //make draggable again
  }

  function updateNote(id, attributes) {
    $.post("note/"+id, attributes);
  }

  $('.note .title').dblclick(function() {
    var title = $(this);
    if (!title.hasClass('editing')) {
      var note = title.closest('.note');
      var inp = $('<input type="text">').val(title.text().trim());
      title.addClass('editing');

      inp.keypress(function(e) {
        if (e.which === 13) {
          var new_title = inp.val().trim();
          updateNote(note.attr('id'), {title: new_title});
          title.html(new_title);
          title.removeClass('editing');
        }
      });
      $(this).html(
        inp.focus()
      );
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
      updateNote(note.attr('id'), {mode_name: mode_id});
    }
  });

});
