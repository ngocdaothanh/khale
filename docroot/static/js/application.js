tinyMCE.init({
  language: 'en',
  mode: 'textareas',
  editor_deselector: 'mce_no_editor',
  add_form_submit_trigger: 1,
  submit_patch: 0,
  content_css: '/static/css/reset.css, /static/css/page.css',
  entity_encoding: 'raw',
  convert_urls: false,
  remove_linebreaks: false,
  button_tile_map: true,
  theme: 'advanced',
  plugins: 'emotions,media,table',
  theme_advanced_toolbar_location: 'top',
  theme_advanced_toolbar_align: 'left',
  theme_advanced_path_location: 'bottom',
  paste_auto_cleanup_on_paste: true,
  theme_advanced_buttons1: 'formatselect,removeformat,bold,italic,underline,strikethrough,sub,sup,forecolor,backcolor,bullist,numlist,blockquote',
  theme_advanced_buttons2: 'table,row_props,cell_props,delete_col,delete_row,col_after,row_after,split_cells,merge_cells,link,unlink,charmap,emotions,image,media,code',
  theme_advanced_buttons3: ''
});

function more(a) {
    $(a).hide();
    $(a).after('<img class="ajax-loader" src="/static/img/ajax-loader.gif" />');
    var url = a.href + '?without_layout=true';
    $.get(url, function(Html) {
        $(a).replaceWith(Html);
        $('.ajax-loader').remove();
    });
    return false;
};

function chatMore(now) {
    // Scroll down
    var output = $('#chat_output');
    output[0].scrollTop = output[0].scrollHeight;

    $.post('/chats/' + now, null, function(data) {
        var numUsers = data.numUsers;
        if (numUsers != null) {
            $('#chat_users').html('' + numUsers + '');
        }

        var msgs = data.msgs;
        if (msgs != null) {
            var ul = $('#chat_output ul');
            for (var i = 0; i < msgs.length; i++) {
                var escaped = $('<div/>').text(msgs[i]).html();
                ul.append("<li>" + escaped + "</li>");
            }
        }

        var now2 = data.now;
        now3 = (now2 == null)? now : now2;
        chatMore(now3);
    }, "json");
};

$(function() {
    $('#chat_input').keydown(function(evt) {
        if (evt.keyCode == 13) {
            var input = $('#chat_input');
            var msg = $.trim(input.val());
            if (msg != '') {
                $.post('/chats', {msg: msg});
            }
            input.val('');
        }
    });
});
