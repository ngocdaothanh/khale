$('a.tag').click(function() {
    var tag   = this.innerHTML;
    var input = $('input.textbox[name=tags]');
    var val   = jQuery.trim(input.val());
    var tag2  = (val == '')? tag : (', ' + tag);
    input.val(val + tag2);
    return false;
});
