Dict = require './dictcc'

module.exports = Dictator =

  activate: (state) =>
    @dict = new Dict()

  deactivate: =>
    @dict.destroy()

  serialize: =>
    return @dict.serialize();
