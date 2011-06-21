$(document).ready(function(){
  $.fn.DragArticles = function() {
    // set up draggable elements
    $(".listing > tbody > tr.dropTarget").draggable({
      appendTo:"body",
    cursor:"pointer",
    cursorAt:{top:20,left:100},
    helper:function(){
      //this is the drag box that you see when you drag
      return $('<div class="dragBox"><p>Drag to change the<br/> ordering of this article</p></div>');
    }
    });

    //set up the droppable list elements
    $(".listing > tbody > tr.dropTarget").droppable({
      accept: ".listing > tr.dropTarget",
      hoverClass: 'droppable-hover',
      tolerance: 'pointer',
      drop: function(ev, ui) {
        var dropEl = this;
        var dragEl = $(ui.draggable);

        // Get Item we are moving
        var currentNoteId = dragEl.find("input:hidden").get(0).value;
        var currentMode   = dragEl.find("input:hidden").get(1).value;

        // get order
        // if they are different, we need to find out if it is above or below
        //var dropOrder = 0;
        // lastObj will contain the element of where we need to insertBefore...

        //var lastObj;

        var newMode = $(dropEl).find("input:hidden").get(1).value;

        // set lastObj
        //lastObj = $(dropEl);

        //if (currentModeId != newModeId)
        //	dragEl.insertAfter(dropEl);
        //if (currentModeID != newModeID) {
        //  //$(this).find("input:hidden").get(1).value = newModeID
        //  function() {
            $(".listing > tbody > tr").each(
              //function {
            alert('HelloWorld');
              $(this)
              //}
              //function(intIndex) {

              //}
        //        if ( $(this).find("input:hidden").get(0).value == currenNoteId) {
                  //$(this).addClass("alt");
        //        }
            );
        //  }
        //}	

        // insert before lastObj
        //if (isBefore)
        //	dragEl.insertBefore(lastObj);
        //else
        //	dragEl.insertAfter(lastObj);

        // loop through all draggables and update their counts
        //$(".listing > tbody > tr.dropTarget").each(
        //	function(intIndex) {
        //	if (intIndex % 2 == 0) {
        //		$(this).removeClass("alt");
        //	} else {
        //		$(this).addClass("alt");
        //  }
        //if (currentModeID != newModeID) {
        //   $(this).find("input:hidden").get(1).value = newModeID
        // adjust the rowcount
        //if (isBefore) {
        //	// move everything up by 1
        //	if ($(this).find("input:hidden").get(1).value >= dropOrder)
        //		$(this).find("input:hidden").get(1).value++;
        //} else {
        //	// move everything down by 1
        //	if ($(this).find("input:hidden").get(1).value <= dropOrder)
        //		$(this).find("input:hidden").get(1).value--;
        //}
        //	} else {
        //	$(this).find("input:hidden").get(1).value = dropOrder;
        //}
        //});

        // set the url of our php page that will accept an articleid and position to update it
        var url = "pageThatDoesArticleUpdate.php?articleid=" + articleId + "&position=" + dropOrder;
        $.get(url);
      }
    });
  }

  $(function(){ $("#content").DragArticles();});
});
