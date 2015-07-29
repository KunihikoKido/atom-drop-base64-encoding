{CompositeDisposable} = require 'atom'

module.exports = DropBase64Encoding =
  subscriptions: null

  activate: (state) ->
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

        for f in files
          console.log(f)
          if fs.lstatSync(f.path).isFile()
            buffer = new Buffer(fs.readFileSync(f.path))
            base64String = buffer.toString('base64')
            editor.insertText "#{base64String}"
      )
    )

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
