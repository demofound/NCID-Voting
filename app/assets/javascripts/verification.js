$(document).ready(function(){
    $("#verification_steps .continue, #verification_steps .back").click(function(ev){
        ev.preventDefault();
        var $self = $(this);
        var forward = $self.hasClass("continue");
        $self.parents(".step:first").slideUp(200)[forward ? "next" : "prev"]().slideDown(200);
        return false;
    });
});
