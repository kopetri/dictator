scrape = require 'scrapeit'

module.exports =
  class Parser
    constructor: (callback) ->
      @callback = callback

    get_response_scrape: (word, from_language, to_language) =>
      return unless @callback?
      subdomain = from_language.toLowerCase()+to_language.toLowerCase()
      url = "http://"+subdomain+".dict.cc/?s=" + encodeURI(word)
      @word_ = word
      @from_lang = from_language
      @to_lang = to_language
      scrape(url,(err,o,dom)=>
        @callback(@parse_response(o))
      )

    parse_response: (response_body) =>
      return null unless response_body?
      in_words = [];
      out_words= [];
      result = [];
      response_body("tr").forEach((tr)=>
        if tr.attribs and tr.attribs.id and /tr\d/.test(tr.attribs.id)
          in_words = in_words.concat(@parse_words_DICTCC(tr.children[2]))
          out_words = out_words.concat(@parse_words_DICTCC(tr.children[1]))
      )
      return @add_arrays(in_words,out_words)

    add_arrays: (a,b) ->
      return null unless a?.length == b?.length
      c = []
      a.forEach((elem,index,array)=>
        c.push({
          in: elem,
          out: b[index]
          })
      )
      return c

    parse_words_DICTCC: (obj) =>
      if obj.attribs and obj.attribs.dir =="ltr"
        children = obj.children
        phrase = ""
        words = []
        children.forEach((child)=>
          if child.name == "a" and child.type == "tag"
            if child.children[0]?.type == "text"
              word = child.children[0].data
              index = word.indexOf("=")
              if index > -1
                word = word.substring(index+2, word.length - 1)
              phrase += word + " "
            else if child.children[0].children?.length
              if child.children[0].children[0]?.type == "text"
                word = child.children[0].children[0].data
                index = word.indexOf("=")
                if index > -1
                  word = word.substring(index+2, word.length - 1)
                phrase += word + " "
        )
        phrase = phrase.substring(0, phrase.length - 1)
        words.push(phrase)
        return words
