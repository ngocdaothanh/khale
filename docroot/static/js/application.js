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

function discussionDelete(id) {
    $("#discussion_" + id).remove();
    $.post('/discussions/' + id, {_method: "delete"});
}

$(function() {
    $('#search_keyword').keydown(function(evt) {
        if (evt.keyCode == 13) {
            var input = $(this);
            var keyword = $.trim(input.val());
            if (keyword != '') {
                window.location.href = '/search/' + encodeURIComponent(keyword);
            }
        }
    });

    $('#chat_input').keydown(function(evt) {
        if (evt.keyCode == 13) {
            var input = $(this);
            var msg = $.trim(input.val());
            if (msg != '') {
                $.post('/chats', {msg: msg});
            }
            input.val('');
        }
    });

    $('#discussion_composer input.button').click(function() {
        $(this).hide();
        $(this).after('<img class="ajax-loader" src="/static/img/ajax-loader.gif" />');

        var contentType = $('#discussion_composer input[name="content_type"]').val();
        var contentId = $('#discussion_composer input[name="content_id"]').val();

        tinyMCE.triggerSave();
        var body = $('#discussion_composer textarea').val();
        var answer = $('#discussion_composer input.textbox').val();
        var encryptedAnswer = $('#discussion_composer input[name="encrypted_answer"]').val();

        var url = '/discussions/' + contentType + '/' + contentId;
        var postData = {body: body, answer: answer, encrypted_answer: encryptedAnswer};
        $.post(url, postData, function(data) {
            if (data.error) {
                alert(data.error);
            } else {
                $('.discussions').append(data.atomic);
            }
            $('#discussion_composer .ajax-loader').remove();
            $('#discussion_composer input.button').show();
        }, "json");
    });
});
