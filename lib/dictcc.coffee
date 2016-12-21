Parser = require './parser'
DictatorView = require './dictator-view'
{ CompositeDisposable } = require 'atom'

module.exports =
class Dict
  constructor: ->
    @AVAILABLE_LANGUAGES = {
      "en": "english",
      "de": "german",
      "fr": "french",
      "sv": "swedish",
      "es": "spanish",
      "bg": "bulgarian",
      "ro": "romanian",
      "it": "italian",
      "pt": "portuguese",
      "ru": "russian"
    }
    
    @keyword_regex = new RegExp("\\\\w*("+@getKeywords()+")({|{[^}]+,)([a-zA-Z]+)(}|[^}]}+,)$","g")
    @dictatorView = new DictatorView(@onTranslationSelected);
    @parser = new Parser(@dictatorView.updateItems);

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable();
    @subscriptions.add(atom.workspace.observeTextEditors((editor)=>
      @editor = editor
    ))
    @subscribeBuffer();

  getKeywords: =>
    arr = Object.keys(@AVAILABLE_LANGUAGES)
    result = ""
    arr.forEach((elem)->
      arr.forEach((elem2)->
        if elem != elem2
          result += elem+elem2+"|"
          result += elem2+elem+"|"
      )
    )
    result = result.substring(0, result.length - 1)
    return result




  subscribeBuffer: =>
    @unsubscribeBuffer()
    return unless @editor?
    @buffer = @editor.getBuffer()
    @disposableBuffer = @buffer.onDidStopChanging(@editorHook)

  editorHook: =>
    return unless @editor?
    cursor = @editor.getCursorBufferPosition()
    line = @editor.getTextInBufferRange([[cursor.row, 0],[cursor.row, cursor.column+1]])
    match = line.match(@keyword_regex)
    if @extract_word_from_match(match?[0])?.length
      @translate(@extract_word_from_match(match[0]),@extract_keyword_from_match(match[0])?.from_lang,@extract_keyword_from_match(match[0])?.to_lang)
    else
      @dictatorView.hide()

  extract_keyword_from_match: (match) ->
      return null unless match?
      keyword = match.split("{")?[0].replace("\\","")
      return null unless keyword.length == 4
      return {
        from_lang: keyword.substring(0, 2)
        to_lang: keyword.substring(2,4)
      }

  extract_word_from_match: (match) ->
    return null unless match?
    right_match = match.split("{")[1]
    return null unless right_match?
    return right_match.split("}")?[0]

  unsubscribeBuffer: =>
    return unless @disposableBuffer?
    @disposableBuffer.dispose()
    @buffer = null


  destroy: =>
    @subscriptions.dispose()
    @dictatorView.destroy()


  serialize:=>
    return {
    dictatorViewState: @dictatorView.serialize()
    }

  translate: (word, from_language, to_language) =>
    if @isAvailableLanguage(from_language) and @isAvailableLanguage(to_language)
      @parser.get_response_scrape(word, from_language, to_language)

  onTranslationSelected: (translation) =>
    cursor = @editor.getCursorBufferPosition()
    line = @editor.getTextInBufferRange([[cursor.row, 0],[cursor.row, cursor.column+1]])
    @editor.setTextInBufferRange([[cursor.row, 0],[cursor.row, cursor.column+1]],line.replace(@keyword_regex,translation.out))

  isAvailableLanguage: (lang) =>
    if Object.keys(@AVAILABLE_LANGUAGES).indexOf(lang) <= -1
      return false
    return true
