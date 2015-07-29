{CompositeDisposable} = require 'atom'

module.exports = DropBase64Encoding =
  subscriptions: null

  activate: (state) ->
    console.log("activate!")
    # Events subscribed to in atom's system can be easily cleaned up
    # with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors((editor) ->
      textEditorElement = atom.views.getView(editor)
      textEditorElement.addEventListener("drop", (e) ->
        e.preventDefault?()
        e.stopPropagation?()

        files = e.dataTransfer.files

        fs = require 'fs-plus'

        for i in [0...files.length]
          console.log(files[i])
          buffer = new Buffer(fs.readFileSync(files[i].path))
          base64String = buffer.toString('base64')
          editor.insertText "#{base64String}"
      )
    )

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
