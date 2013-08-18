# EditableJS Controller
# ---------------------
# Integrate EditableJS into Livingdocs
class EditableController


  constructor: (@page) ->

    # configure editableJS
    Editable.init
      log: false

    @selection = $.Callbacks()

    Editable
      .focus($.proxy(@focus, @))
      .blur($.proxy(@blur, @))
      .insert($.proxy(@insert, @))
      .split($.proxy(@split, @))
      .selection($.proxy(@selectionChanged, @))


  add: (nodes) ->
    Editable.add(nodes)


  focus: (element) ->
    snippetElem = dom.parentSnippetElem(element)
    @page.focus.editableFocused(element, snippetElem)


  blur: (element) ->
    snippetElem = dom.parentSnippetElem(element)
    @page.focus.editableBlurred(element, snippetElem)
    editableName = element.getAttribute(docAttr.editable)
    snippetElem.model.set(editableName, element.innerHTML)


  insert: (element, direction, cursor) ->
    snippetElem = dom.parentSnippetElem(element)
    template = snippetElem.template
    if template.editableCount == 1
      copy = template.createModel()
      snippetElem.model.after(copy)
      if copiedElem = snippetElem.next()
        copiedElem.focus()

    false # disable editableJS default behaviour


  split: (element, before, after, cursor) ->
    log('engine: split')
    false # disable editableJS default behaviour


  selectionChanged: (element, selection) ->
    snippetElem = dom.parentSnippetElem(element)
    @selection.fire(snippetElem, element, selection)

