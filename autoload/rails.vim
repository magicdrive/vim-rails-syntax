" autoload/rails.vim
" Author:       Tim Pope <http://tpo.pe/>

" Install this file as autoload/rails.vim.

if exists('g:autoloaded_rails_syntax') || &cp
  finish
endif
let g:autoloaded_rails_syntax = '5.2'

" Syntax {{{1

function! s:resetomnicomplete()
  if exists("+completefunc") && &completefunc == 'syntaxcomplete#Complete'
    if exists("g:loaded_syntax_completion")
      " Ugly but necessary, until we have our own completion
      unlet g:loaded_syntax_completion
      silent! delfunction syntaxcomplete#Complete
    endif
  endif
endfunction

function! s:helpermethods()
  return ""
        \."action_name asset_path asset_url atom_feed audio_path audio_tag audio_url auto_discovery_link_tag "
        \."button_tag button_to "
        \."cache cache_fragment_name cache_if cache_unless capture cdata_section check_box check_box_tag collection_check_boxes collection_radio_buttons collection_select color_field color_field_tag compute_asset_extname compute_asset_host compute_asset_path concat content_for content_tag content_tag_for controller controller_name controller_path convert_to_model cookies csrf_meta_tag csrf_meta_tags current_cycle cycle "
        \."date_field date_field_tag date_select datetime_field datetime_field_tag datetime_local_field datetime_local_field_tag datetime_select debug distance_of_time_in_words distance_of_time_in_words_to_now div_for dom_class dom_id "
        \."email_field email_field_tag escape_javascript escape_once excerpt "
        \."favicon_link_tag field_set_tag fields_for file_field file_field_tag flash font_path font_url form_for form_tag "
        \."grouped_collection_select grouped_options_for_select "
        \."headers hidden_field hidden_field_tag highlight "
        \."image_alt image_path image_submit_tag image_tag image_url "
        \."j javascript_cdata_section javascript_include_tag javascript_path javascript_tag javascript_url "
        \."l label label_tag link_to link_to_if link_to_unless link_to_unless_current localize logger "
        \."mail_to month_field month_field_tag "
        \."number_field number_field_tag number_to_currency number_to_human number_to_human_size number_to_percentage number_to_phone number_with_delimiter number_with_precision "
        \."option_groups_from_collection_for_select options_for_select options_from_collection_for_select "
        \."params password_field password_field_tag path_to_asset path_to_audio path_to_font path_to_image path_to_javascript path_to_stylesheet path_to_video phone_field phone_field_tag pluralize provide "
        \."radio_button radio_button_tag range_field range_field_tag raw render request request_forgery_protection_token reset_cycle response "
        \."safe_concat safe_join sanitize sanitize_css search_field search_field_tag select select_date select_datetime select_day select_hour select_minute select_month select_second select_tag select_time select_year session simple_format strip_links strip_tags stylesheet_link_tag stylesheet_path stylesheet_url submit_tag "
        \."t tag telephone_field telephone_field_tag text_area text_area_tag text_field text_field_tag time_ago_in_words time_field time_field_tag time_select time_tag time_zone_options_for_select time_zone_select translate truncate "
        \."url_field url_field_tag url_for url_to_asset url_to_audio url_to_font url_to_image url_to_javascript url_to_stylesheet url_to_video utf8_enforcer_tag "
        \."video_path video_tag video_url "
        \."week_field week_field_tag word_wrap"
endfunction

function! s:app_user_classes() dict
  if self.cache.needs("user_classes")
    let controllers = self.relglob("app/controllers/","**/*",".rb")
    call map(controllers,'v:val == "application" ? v:val."_controller" : v:val')
    let classes =
          \ self.relglob("app/models/","**/*",".rb") +
          \ controllers +
          \ self.relglob("app/helpers/","**/*",".rb") +
          \ self.relglob("lib/","**/*",".rb")
    call map(classes,'rails#camelize(v:val)')
    call self.cache.set("user_classes",classes)
  endif
  return self.cache.get('user_classes')
endfunction

function! s:app_user_assertions() dict
  if self.cache.needs("user_assertions")
    if self.has_file("test/test_helper.rb")
      let assertions = map(filter(s:readfile(self.path("test/test_helper.rb")),'v:val =~ "^  def assert_"'),'matchstr(v:val,"^  def \\zsassert_\\w\\+")')
    else
      let assertions = []
    endif
    call self.cache.set("user_assertions",assertions)
  endif
  return self.cache.get('user_assertions')
endfunction

call s:add_methods('app', ['user_classes','user_assertions'])

function! rails#buffer_syntax()
  if !exists("g:rails_no_syntax")
    let buffer = rails#buffer()
    let keywords = split(join(buffer.projected('keywords'), ' '))
    let special = filter(copy(keywords), 'v:val =~# ''^\h\k*[?!]$''')
    let regular = filter(copy(keywords), 'v:val =~# ''^\h\k*$''')
    if &syntax == 'ruby'
      if !empty(special)
        exe 'syn match rubyRailsMethod "\<\%('.join(special, '\|').'\)"'
      endif
      if !empty(regular)
        exe 'syn keyword rubyRailsMethod '.join(regular, ' ')
      endif
      if buffer.type_name() == ''
        syn keyword rubyRailsMethod params request response session headers cookies flash
      endif
      if buffer.type_name() ==# 'model' || buffer.type_name('model-arb')
        syn keyword rubyRailsARMethod default_scope enum named_scope scope serialize store
        syn keyword rubyRailsARAssociationMethod belongs_to has_one has_many has_and_belongs_to_many composed_of accepts_nested_attributes_for
        syn keyword rubyRailsARCallbackMethod before_create before_destroy before_save before_update before_validation before_validation_on_create before_validation_on_update
        syn keyword rubyRailsARCallbackMethod after_create after_destroy after_save after_update after_validation after_validation_on_create after_validation_on_update
        syn keyword rubyRailsARCallbackMethod around_create around_destroy around_save around_update
        syn keyword rubyRailsARCallbackMethod after_commit after_find after_initialize after_rollback after_touch
        syn keyword rubyRailsARClassMethod attr_accessible attr_protected attr_readonly has_secure_password store_accessor
        syn keyword rubyRailsARValidationMethod validate validates validate_on_create validate_on_update validates_acceptance_of validates_associated validates_confirmation_of validates_each validates_exclusion_of validates_format_of validates_inclusion_of validates_length_of validates_numericality_of validates_presence_of validates_size_of validates_uniqueness_of validates_with
        syn keyword rubyRailsMethod logger
      endif
      if buffer.type_name('model-aro')
        syn keyword rubyRailsARMethod observe
      endif
      if buffer.type_name('mailer')
        syn keyword rubyRailsMethod logger url_for polymorphic_path polymorphic_url
        syn keyword rubyRailsRenderMethod mail render
        syn keyword rubyRailsControllerMethod attachments default helper helper_attr helper_method layout
      endif
      if buffer.type_name('helper','view')
        syn keyword rubyRailsViewMethod polymorphic_path polymorphic_url
        exe "syn keyword rubyRailsHelperMethod ".s:gsub(s:helpermethods(),'<%(content_for|select)\s+','')
        syn match rubyRailsHelperMethod '\<select\>\%(\s*{\|\s*do\>\|\s*(\=\s*&\)\@!'
        syn match rubyRailsHelperMethod '\<\%(content_for?\=\|current_page?\)'
        syn match rubyRailsViewMethod '\.\@<!\<\(h\|html_escape\|u\|url_encode\)\>'
        if buffer.type_name('view-partial')
          syn keyword rubyRailsMethod local_assigns
        endif
      elseif buffer.type_name('controller')
        syn keyword rubyRailsMethod params request response session headers cookies flash
        syn keyword rubyRailsRenderMethod render
        syn keyword rubyRailsMethod logger polymorphic_path polymorphic_url
        syn keyword rubyRailsControllerMethod helper helper_attr helper_method filter layout url_for serialize exempt_from_layout filter_parameter_logging hide_action cache_sweeper protect_from_forgery caches_page cache_page caches_action expire_page expire_action rescue_from
        syn keyword rubyRailsRenderMethod head redirect_to render_to_string respond_with
        syn match   rubyRailsRenderMethod '\<respond_to\>?\@!'
        syn keyword rubyRailsFilterMethod before_filter append_before_filter prepend_before_filter after_filter append_after_filter prepend_after_filter around_filter append_around_filter prepend_around_filter skip_before_filter skip_after_filter skip_filter before_action append_before_action prepend_before_action after_action append_after_action prepend_after_action around_action append_around_action prepend_around_action skip_before_action skip_after_action skip_action
        syn keyword rubyRailsFilterMethod verify
      endif
      if buffer.type_name('db-migration','db-schema')
        syn keyword rubyRailsMigrationMethod create_table change_table drop_table rename_table create_join_table drop_join_table
        syn keyword rubyRailsMigrationMethod add_column rename_column change_column change_column_default change_column_null remove_column remove_columns
        syn keyword rubyRailsMigrationMethod add_foreign_key remove_foreign_key
        syn keyword rubyRailsMigrationMethod add_timestamps remove_timestamps
        syn keyword rubyRailsMigrationMethod add_reference remove_reference add_belongs_to remove_belongs_to
        syn keyword rubyRailsMigrationMethod add_index remove_index rename_index
        syn keyword rubyRailsMigrationMethod execute transaction reversible revert
      endif
      if buffer.type_name('test')
        if !empty(rails#app().user_assertions())
          exe "syn keyword rubyRailsUserMethod ".join(rails#app().user_assertions())
        endif
        syn keyword rubyRailsTestMethod refute refute_empty refute_equal refute_in_delta refute_in_epsilon refute_includes refute_instance_of refute_kind_of refute_match refute_nil refute_operator refute_predicate refute_respond_to refute_same
        syn keyword rubyRailsTestMethod add_assertion assert assert_block assert_equal assert_in_delta assert_instance_of assert_kind_of assert_match assert_nil assert_no_match assert_not assert_not_equal assert_not_nil assert_not_same assert_nothing_raised assert_nothing_thrown assert_operator assert_raise assert_respond_to assert_same assert_send assert_throws assert_recognizes assert_generates assert_routing flunk fixtures fixture_path use_transactional_fixtures use_instantiated_fixtures assert_difference assert_no_difference assert_valid
        syn keyword rubyRailsTestMethod test setup teardown
        if !buffer.type_name('test-unit')
          syn match   rubyRailsTestControllerMethod  '\.\@<!\<\%(get\|post\|put\|patch\|delete\|head\|process\|assigns\)\>'
          syn keyword rubyRailsTestControllerMethod get_via_redirect post_via_redirect put_via_redirect delete_via_redirect request_via_redirect
          syn keyword rubyRailsTestControllerMethod assert_response assert_redirected_to assert_template assert_recognizes assert_generates assert_routing assert_dom_equal assert_dom_not_equal assert_select assert_select_rjs assert_select_encoded assert_select_email assert_tag assert_no_tag
        endif
      elseif buffer.type_name('spec')
        syn keyword rubyRailsTestMethod describe context it its specify shared_context shared_examples shared_examples_for shared_context include_examples include_context it_should_behave_like it_behaves_like before after around subject fixtures controller_name helper_name scenario feature background given described_class
        syn match rubyRailsTestMethod '\<let\>!\='
        syn keyword rubyRailsTestMethod violated pending expect expect_any_instance_of allow allow_any_instance_of double instance_double mock mock_model stub_model xit
        syn match rubyRailsTestMethod '\.\@<!\<stub\>!\@!'
        if !buffer.type_name('spec-model')
          syn match   rubyRailsTestControllerMethod  '\.\@<!\<\%(get\|post\|put\|patch\|delete\|head\|process\|assigns\)\>'
          syn keyword rubyRailsTestControllerMethod  integrate_views render_views
          syn keyword rubyRailsMethod params request response session flash
          syn keyword rubyRailsMethod polymorphic_path polymorphic_url
          if buffer.type_name('spec-view')
            syn keyword rubyRailsTestViewMethod render rendered assign
          elseif buffer.type_name('spec-helper')
            syn keyword RubyRailsTestHelperMethod helper
          endif
        endif
      endif
      if buffer.type_name('task')
        syn match rubyRailsRakeMethod '^\s*\zs\%(task\|file\|namespace\|desc\|before\|after\|on\)\>\%(\s*=\)\@!'
      endif
      if buffer.type_name('config-routes')
        syn match rubyRailsMethod '\.\zs\%(connect\|named_route\)\>'
        syn keyword rubyRailsMethod match get put patch post delete redirect root resource resources collection member nested scope namespace controller constraints mount concern
      endif
      syn keyword rubyRailsMethod debugger
      syn keyword rubyRailsMethod alias_attribute alias_method_chain attr_accessor_with_default attr_internal attr_internal_accessor attr_internal_reader attr_internal_writer concerning delegate mattr_accessor mattr_reader mattr_writer superclass_delegating_accessor superclass_delegating_reader superclass_delegating_writer with_options
      syn keyword rubyRailsMethod cattr_accessor cattr_reader cattr_writer class_inheritable_accessor class_inheritable_array class_inheritable_array_writer class_inheritable_hash class_inheritable_hash_writer class_inheritable_option class_inheritable_reader class_inheritable_writer inheritable_attributes read_inheritable_attribute reset_inheritable_attributes write_inheritable_array write_inheritable_attribute write_inheritable_hash
      syn keyword rubyRailsInclude require_dependency

      syn region  rubyString   matchgroup=rubyStringDelimiter start=+\%(:order\s*=>\s*\)\@<="+ skip=+\\\\\|\\"+ end=+"+ contains=@rubyStringSpecial,railsOrderSpecial
      syn region  rubyString   matchgroup=rubyStringDelimiter start=+\%(:order\s*=>\s*\)\@<='+ skip=+\\\\\|\\'+ end=+'+ contains=@rubyStringSpecial,railsOrderSpecial
      syn match   railsOrderSpecial +\c\<\%(DE\|A\)SC\>+ contained
      syn region  rubyString   matchgroup=rubyStringDelimiter start=+\%(:conditions\s*=>\s*\[\s*\)\@<="+ skip=+\\\\\|\\"+ end=+"+ contains=@rubyStringSpecial,railsConditionsSpecial
      syn region  rubyString   matchgroup=rubyStringDelimiter start=+\%(:conditions\s*=>\s*\[\s*\)\@<='+ skip=+\\\\\|\\'+ end=+'+ contains=@rubyStringSpecial,railsConditionsSpecial
      syn match   railsConditionsSpecial +?\|:\h\w*+ contained
      syn cluster rubyNotTop add=railsOrderSpecial,railsConditionsSpecial

    elseif &syntax =~# '^eruby\>' || &syntax == 'haml'
      let containedin = 'contained containedin=@'.&syntax.'RailsRegions'
      syn case match
      if !empty(special)
        exe 'syn match '.&syntax.'RailsMethod "\<\%('.join(special, '\|').'\)"' containedin
      endif
      if !empty(regular)
        exe 'syn keyword '.&syntax.'RailsMethod '.join(regular, ' ') containedin
      endif
      if &syntax == 'haml'
        exe 'syn cluster hamlRailsRegions contains=hamlRubyCodeIncluded,hamlRubyCode,hamlRubyHash,@hamlEmbeddedRuby,rubyInterpolation'
      else
        exe 'syn cluster erubyRailsRegions contains=erubyOneLiner,erubyBlock,erubyExpression,rubyInterpolation'
      endif
      exe 'syn keyword '.&syntax.'RailsHelperMethod '.s:gsub(s:helpermethods(),'<%(content_for|select)\s+','').' contained containedin=@'.&syntax.'RailsRegions'
      exe 'syn match '.&syntax.'RailsHelperMethod "\<select\>\%(\s*{\|\s*do\>\|\s*(\=\s*&\)\@!" contained containedin=@'.&syntax.'RailsRegions'
      exe 'syn match '.&syntax.'RailsHelperMethod "\<\%(content_for?\=\|current_page?\)" contained containedin=@'.&syntax.'RailsRegions'
      exe 'syn keyword '.&syntax.'RailsMethod debugger polymorphic_path polymorphic_url contained containedin=@'.&syntax.'RailsRegions'
      exe 'syn match '.&syntax.'RailsViewMethod "\.\@<!\<\(h\|html_escape\|u\|url_encode\)\>" contained containedin=@'.&syntax.'RailsRegions'
      if buffer.type_name('view-partial')
        exe 'syn keyword '.&syntax.'RailsMethod local_assigns contained containedin=@'.&syntax.'RailsRegions'
      endif
      exe 'syn keyword '.&syntax.'RailsRenderMethod render contained containedin=@'.&syntax.'RailsRegions'
      exe 'syn case match'
    elseif &syntax == "yaml"
      syn case match
      unlet! b:current_syntax
      let g:main_syntax = 'eruby'
      syn include @rubyTop syntax/ruby.vim
      unlet g:main_syntax
      syn cluster yamlRailsRegions contains=yamlRailsOneLiner,yamlRailsBlock,yamlRailsExpression
      syn region  yamlRailsOneLiner   matchgroup=yamlRailsDelimiter start="^%%\@!" end="$"  contains=@rubyRailsTop      containedin=ALLBUT,@yamlRailsRegions,yamlRailsComment keepend oneline
      syn region  yamlRailsBlock      matchgroup=yamlRailsDelimiter start="<%%\@!" end="%>" contains=@rubyTop           containedin=ALLBUT,@yamlRailsRegions,yamlRailsComment
      syn region  yamlRailsExpression matchgroup=yamlRailsDelimiter start="<%="    end="%>" contains=@rubyTop           containedin=ALLBUT,@yamlRailsRegions,yamlRailsComment
      syn region  yamlRailsComment    matchgroup=yamlRailsDelimiter start="<%#"    end="%>" contains=rubyTodo,@Spell    containedin=ALLBUT,@yamlRailsRegions,yamlRailsComment keepend
      syn match yamlRailsMethod '\.\@<!\<\(h\|html_escape\|u\|url_encode\)\>' contained containedin=@yamlRailsRegions
      let b:current_syntax = "yaml"

    elseif &syntax == "scss" || &syntax == "sass"
      syn match sassFunction "\<\%(\%(asset\|image\|font\|video\|audio\|javascript\|stylesheet\)-\%(url\|path\)\)\>(\@=" contained
      syn match sassFunction "\<\asset-data-url\>(\@=" contained
    endif
  endif
  call s:HiDefaults()
endfunction

function! s:HiDefaults()
  hi def link rubyRailsAPIMethod              rubyRailsMethod
  hi def link rubyRailsARAssociationMethod    rubyRailsARMethod
  hi def link rubyRailsARCallbackMethod       rubyRailsARMethod
  hi def link rubyRailsARClassMethod          rubyRailsARMethod
  hi def link rubyRailsARValidationMethod     rubyRailsARMethod
  hi def link rubyRailsARMethod               rubyRailsMethod
  hi def link rubyRailsRenderMethod           rubyRailsMethod
  hi def link rubyRailsHelperMethod           rubyRailsMethod
  hi def link rubyRailsViewMethod             rubyRailsMethod
  hi def link rubyRailsMigrationMethod        rubyRailsMethod
  hi def link rubyRailsControllerMethod       rubyRailsMethod
  hi def link rubyRailsFilterMethod           rubyRailsMethod
  hi def link rubyRailsTestControllerMethod   rubyRailsTestMethod
  hi def link rubyRailsTestViewMethod         rubyRailsTestMethod
  hi def link rubyRailsTestHelperMethod       rubyRailsTestMethod
  hi def link rubyRailsTestMethod             rubyRailsMethod
  hi def link rubyRailsRakeMethod             rubyRailsMethod
  hi def link rubyRailsMethod                 railsMethod
  hi def link rubyRailsInclude                rubyInclude
  hi def link rubyRailsUserClass              railsUserClass
  hi def link rubyRailsUserMethod             railsUserMethod
  hi def link erubyRailsHelperMethod          erubyRailsMethod
  hi def link erubyRailsViewMethod            erubyRailsMethod
  hi def link erubyRailsRenderMethod          erubyRailsMethod
  hi def link erubyRailsMethod                railsMethod
  hi def link erubyRailsUserMethod            railsUserMethod
  hi def link erubyRailsUserClass             railsUserClass
  hi def link hamlRailsHelperMethod           hamlRailsMethod
  hi def link hamlRailsViewMethod             hamlRailsMethod
  hi def link hamlRailsRenderMethod           hamlRailsMethod
  hi def link hamlRailsMethod                 railsMethod
  hi def link hamlRailsUserMethod             railsUserMethod
  hi def link hamlRailsUserClass              railsUserClass
  hi def link railsUserMethod                 railsMethod
  hi def link yamlRailsDelimiter              Delimiter
  hi def link yamlRailsMethod                 railsMethod
  hi def link yamlRailsComment                Comment
  hi def link yamlRailsUserClass              railsUserClass
  hi def link yamlRailsUserMethod             railsUserMethod
  hi def link javascriptRailsFunction         railsMethod
  hi def link railsUserClass                  railsClass
  hi def link railsMethod                     Function
  hi def link railsClass                      Type
  hi def link railsOrderSpecial               railsStringSpecial
  hi def link railsConditionsSpecial          railsStringSpecial
  hi def link railsStringSpecial              Identifier
endfunction

function! rails#log_syntax()
  if has('conceal')
    syn match railslogEscape      '\e\[[0-9;]*m' conceal
    syn match railslogEscapeMN    '\e\[[0-9;]*m' conceal nextgroup=railslogModelNum,railslogEscapeMN skipwhite contained
  else
    syn match railslogEscape      '\e\[[0-9;]*m'
    syn match railslogEscapeMN    '\e\[[0-9;]*m' nextgroup=railslogModelNum,railslogEscapeMN skipwhite contained
  endif
  syn match   railslogRender      '\%(^\s*\%(\e\[[0-9;]*m\)\=\)\@<=\%(Started\|Processing\|Rendering\|Rendered\|Redirected\|Completed\)\>'
  syn match   railslogComment     '^\s*# .*'
  syn match   railslogModel       '\%(^\s*\%(\e\[[0-9;]*m\)*\)\@<=\u\%(\w\|:\)* \%(Load\%( Including Associations\| IDs For Limited Eager Loading\)\=\|Columns\|Exists\|Count\|Create\|Update\|Destroy\|Delete all\)\>' skipwhite nextgroup=railslogModelNum,railslogEscapeMN
  syn match   railslogModel       '\%(^\s*\%(\e\[[0-9;]*m\)*\)\@<=\%(SQL\|CACHE\)\>' skipwhite nextgroup=railslogModelNum,railslogEscapeMN
  syn region  railslogModelNum    start='(' end=')' contains=railslogNumber contained skipwhite
  syn match   railslogNumber      '\<\d\+\>%'
  syn match   railslogNumber      '[ (]\@<=\<\d\+\.\d\+\>\.\@!'
  syn match   railslogNumber      '[ (]\@<=\<\d\+\.\d\+ms\>'
  syn region  railslogString      start='"' skip='\\"' end='"' oneline contained
  syn region  railslogHash        start='{' end='}' oneline contains=railslogHash,railslogString
  syn match   railslogIP          '\<\d\{1,3\}\%(\.\d\{1,3}\)\{3\}\>'
  syn match   railslogTimestamp   '\<\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\>'
  syn match   railslogSessionID   '\<\x\{32\}\>'
  syn match   railslogIdentifier  '^\s*\%(Session ID\|Parameters\|Unpermitted parameters\)\ze:'
  syn match   railslogSuccess     '\<2\d\d \u[A-Za-z0-9 ]*\>'
  syn match   railslogRedirect    '\<3\d\d \u[A-Za-z0-9 ]*\>'
  syn match   railslogError       '\<[45]\d\d \u[A-Za-z0-9 ]*\>'
  syn match   railslogError       '^DEPRECATION WARNING\>'
  syn keyword railslogHTTP        OPTIONS GET HEAD POST PUT PATCH DELETE TRACE CONNECT
  hi def link railslogEscapeMN    railslogEscape
  hi def link railslogEscape      Ignore
  hi def link railslogComment     Comment
  hi def link railslogRender      Keyword
  hi def link railslogModel       Type
  hi def link railslogNumber      Number
  hi def link railslogString      String
  hi def link railslogSessionID   Constant
  hi def link railslogIdentifier  Identifier
  hi def link railslogRedirect    railslogSuccess
  hi def link railslogSuccess     Special
  hi def link railslogError       Error
  hi def link railslogHTTP        Special
endfunction

function! rails#log_setup() abort
  nnoremap <buffer> <silent> R :checktime<CR>
  nnoremap <buffer> <silent> G :checktime<Bar>$<CR>
  nnoremap <buffer> <silent> q :bwipe<CR>
  setlocal modifiable noswapfile autoread
  if exists('+concealcursor')
    setlocal concealcursor=nc conceallevel=2
  else
    silent %s/\%(\e\[[0-9;]*m\|\r$\)//ge
  endif
  setlocal readonly nomodifiable
  $
endfunction

" }}}1
" Detection {{{1

function! s:SetBasePath() abort
  let self = rails#buffer()
  if self.app().path() =~ '://'
    return
  endif
  let add_dot = self.getvar('&path') =~# '^\.\%(,\|$\)'
  let old_path = s:pathsplit(s:sub(self.getvar('&path'),'^\.%(,|$)',''))

  let path = ['lib', 'vendor']
  let path += get(g:, 'rails_path_additions', [])
  let path += get(g:, 'rails_path', [])
  let path += ['app/models/concerns', 'app/controllers/concerns', 'app/controllers', 'app/helpers', 'app/mailers', 'app/models']

  for [key, projection] in items(self.app().projections())
    if get(projection, 'path', 0) is 1 || get(projection, 'autoload', 0) is 1
      let path += split(key, '*')[0]
    endif
  endfor
  let path += filter(self.projected('path'), 'type(v:val) == type("")')

  let path += ['app/*', 'app/views']
  if self.controller_name() != ''
    let path += ['app/views/'.self.controller_name(), 'app/views/application', 'public']
  endif
  if self.app().has('test')
    let path += ['test', 'test/unit', 'test/functional', 'test/integration', 'test/controllers', 'test/helpers', 'test/mailers', 'test/models']
  endif
  if self.app().has('spec')
    let path += ['spec', 'spec/controllers', 'spec/helpers', 'spec/mailers', 'spec/models', 'spec/views', 'spec/lib', 'spec/features', 'spec/requests', 'spec/integration']
  endif
  if self.app().has('cucumber')
    let path += ['features']
  endif
  let path += ['vendor/plugins/*/lib', 'vendor/plugins/*/test', 'vendor/rails/*/lib', 'vendor/rails/*/test']
  call map(path, 'rails#app().path(v:val)')
  let engine_paths = map(copy(self.app().engines()), 'v:val . "/app/*"')
  call self.setvar('&path',(add_dot ? '.,' : '').s:pathjoin(s:uniq(path + [self.app().path()] + old_path + engine_paths)))
endfunction

function! rails#buffer_setup() abort
  if !exists('b:rails_root')
    return ''
  endif
  let self = rails#buffer()
  let b:rails_cached_file_type = self.calculate_file_type()
  call s:BufMappings()
  call s:BufCommands()
  if !empty(findfile('macros/rails.vim', escape(&runtimepath, ' ')))
    runtime! macros/rails.vim
  endif
  silent doautocmd User Rails
  call s:BufProjectionCommands()
  call s:BufAbbreviations()
  call s:SetBasePath()
  let rp = s:gsub(self.app().path(),'[ ,]','\\&')
  if stridx(&tags,rp.'/tags') == -1
    let &l:tags = rp . '/tags,' . rp . '/tmp/tags,' . &tags
  endif
  call self.setvar('&includeexpr','rails#includeexpr(v:fname)')
  call self.setvar('&suffixesadd', s:sub(self.getvar('&suffixesadd'),'^$','.rb'))
  let ft = self.getvar('&filetype')
  if ft =~# '^ruby\>'
    call self.setvar('&define',self.define_pattern())
    " This really belongs in after/ftplugin/ruby.vim but we'll be nice
    if exists('g:loaded_surround') && self.getvar('surround_101') == ''
      call self.setvar('surround_5',   "\r\nend")
      call self.setvar('surround_69',  "\1expr: \1\rend")
      call self.setvar('surround_101', "\r\nend")
    endif
    if exists(':UltiSnipsAddFiletypes') == 2
      UltiSnipsAddFiletypes rails
    elseif exists(':SnipMateLoadScope') == 2
      SnipMateLoadScope rails
    endif
  elseif ft =~# 'yaml\>' || fnamemodify(self.name(),':e') ==# 'yml'
    call self.setvar('&define',self.define_pattern())
  elseif ft =~# '^eruby\>'
    call self.setvar('&define',self.define_pattern())
    if exists("g:loaded_ragtag")
      call self.setvar('ragtag_stylesheet_link_tag', "<%= stylesheet_link_tag '\r' %>")
      call self.setvar('ragtag_javascript_include_tag', "<%= javascript_include_tag '\r' %>")
      call self.setvar('ragtag_doctype_index', 10)
    endif
  elseif ft =~# '^haml\>'
    call self.setvar('&define',self.define_pattern())
    if exists("g:loaded_ragtag")
      call self.setvar('ragtag_stylesheet_link_tag', "= stylesheet_link_tag '\r'")
      call self.setvar('ragtag_javascript_include_tag', "= javascript_include_tag '\r'")
      call self.setvar('ragtag_doctype_index', 10)
    endif
  elseif ft =~# 'html\>'
    call self.setvar('&define', '\<id=["'']\=')
  endif
  if ft =~# '^eruby\>' || ft =~# '^yaml\>'
    if exists("g:loaded_surround")
      if self.getvar('surround_45') == '' || self.getvar('surround_45') == "<% \r %>" " -
        call self.setvar('surround_45', "<% \r %>")
      endif
      if self.getvar('surround_61') == '' " =
        call self.setvar('surround_61', "<%= \r %>")
      endif
      if self.getvar("surround_35") == '' " #
        call self.setvar('surround_35', "<%# \r %>")
      endif
      if self.getvar('surround_101') == '' || self.getvar('surround_101')== "<% \r %>\n<% end %>" "e
        call self.setvar('surround_5',   "<% \r %>\n<% end %>")
        call self.setvar('surround_69',  "<% \1expr: \1 %>\r<% end %>")
        call self.setvar('surround_101', "<% \r %>\n<% end %>")
      endif
    endif
  endif

  compiler rails
  let b:current_compiler = 'rake'
  let &l:makeprg = self.app().rake_command('static')
  let &l:errorformat .= ',chdir '.escape(self.app().path(), ',')

  if exists(':Dispatch') == 2 && !exists('g:autoloaded_dispatch')
    runtime! autoload/dispatch.vim
  endif
  if exists('*dispatch#dir_opt')
    let dir = dispatch#dir_opt(self.app().path())
  endif

  let dispatch = self.projected('dispatch')
  if !empty(dispatch) && exists(dir)
    call self.setvar('dispatch', dir . dispatch[0])
  elseif self.name() =~# '^public'
    call self.setvar('dispatch', ':Preview')
  elseif self.type_name('test', 'spec', 'cucumber')
    call self.setvar('dispatch', ':Runner')
  elseif self.name() =~# '^\%(app\|config\|db\|lib\|log\|README\|Rakefile\)'
    if exists('dir')
      call self.setvar('dispatch',
            \ dir . '-compiler=rails ' .
            \ self.app().rake_command('static') .
            \ ' `=rails#buffer(' . self['#'] . ').default_rake_task(v:lnum)`')
    else
      call self.setvar('dispatch', ':Rake')
    endif
  endif
endfunction

" }}}1
" Initialization {{{1

map <SID>xx <SID>xx
let s:sid = s:sub(maparg("<SID>xx"),'xx$','')
unmap <SID>xx
let s:file = expand('<sfile>:p')

if !exists('s:apps')
  let s:apps = {}
endif

" }}}1
" vim:set sw=2 sts=2:
