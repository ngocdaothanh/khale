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
