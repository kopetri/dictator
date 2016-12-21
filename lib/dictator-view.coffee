{SelectListView} = require 'atom-space-pen-views'

module.exports =
class DictatorView extends SelectListView
 initialize: (callback) =>
   super
   @addClass('overlay from-top')
   @callback = callback
   @panel ?= atom.workspace.addModalPanel(item: this)
   @focusFilterEditor()
   @hide()

 viewForItem: (item) =>
   "<li>#{item.in} - #{item.out}</li>"

 confirmed: (item) =>
   @callback(item)
   @cancel()

 cancelled: =>
   @hide()

 updateItems: (result_obj)=>
   @setItems(result_obj)
   @show()
   @focusFilterEditor()

 show: =>
   @storeFocusedElement()
   @panel.show()

 hide: =>
   @panel.hide()

 destroy: ->
   @panel.destroy()

 serialize: ->
