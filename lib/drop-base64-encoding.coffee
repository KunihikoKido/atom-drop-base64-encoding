{CompositeDisposable} = require 'atom'

module.exports = DropBase64Encoding =
  subscriptions: null

  config:
    enabledBulk:
      title: 'Elasticsearch Bulk Index'
      type: 'boolean'
      default: false
      description: 'Enabled Elasticsearch Bulk Index format.'
    attachmentTypeField:
      title: 'Elasticsearch Attachment Type Field Name'
      type: 'string'
      default: 'my_attachment'
      description: 'Property name for Elasticsearch Bulk Index Attachment type field name'
    index:
      title: 'Elasticsearch Index Name'
      type: 'string'
      default: 'blog'
      description: 'Index Name for Elasticsearch Index name.'
    docType:
      title: 'Elasticsearch Type Name'
      type: 'string'
      default: 'posts'
      description: 'Type Name for Elasticsearch Type name.'

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

        enabledBulk = atom.config.get(
          'drop-base64-encoding.enabledBulk')
        index = atom.config.get(
          'drop-base64-encoding.index')
        docType = atom.config.get(
          'drop-base64-encoding.docType')
        attachmentTypeField = atom.config.get(
          'drop-base64-encoding.attachmentTypeField')

        files = e.dataTransfer.files

        fs = require 'fs-plus'

        for f in files
          console.log(f)
          if fs.lstatSync(f.path).isFile()
            buffer = new Buffer(fs.readFileSync(f.path))
            base64String = buffer.toString('base64')
            if enabledBulk
              action = {"index": {}}
              action.index._index = index
              action.index._type = docType
              action.index._id = f.path
              action = JSON.stringify(action)

              source = {}
              source[attachmentTypeField] = base64String
              source = JSON.stringify(source)

              editor.insertText("#{action}\r\n")
              editor.insertText("#{source}\r\n")
            else
              editor.insertText "#{base64String}"
      )
    )

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
