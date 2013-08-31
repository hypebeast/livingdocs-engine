# SnippetModel
# ------------
# Each SnippetModel has a template which allows to generate a snippetView
# from a snippetModel
#
# Represents a node in a SnippetTree.
# Every SnippetModel can have a parent (SnippetContainer),
# siblings (other snippets) and multiple containers (SnippetContainers).
#
# The containers are the parents of the child SnippetModels.
# E.g. a grid row would have as many containers as it has
# columns
#
# # @prop parentContainer: parent SnippetContainer
class SnippetModel


  constructor: ({ @template, id } = {}) ->
    assert @template, 'cannot instantiate snippet without template reference'

    @initializeContainers()
    @initializeEditables()
    @initializeImages()

    @id = id || guid.next()
    @identifier = @template.identifier

    @next = undefined # set by SnippetContainer
    @previous = undefined # set by SnippetContainer
    @snippetTree = undefined # set by SnippetTree


  initializeContainers: ->
    @containerCount = @template.directives.count.container
    for containerName of @template.directives.container
      @containers ||= {}
      @containers[containerName] = new SnippetContainer
        name: containerName
        parentSnippet: this


  initializeEditables: ->
    @editableCount = @template.directives.count.editable
    for editableName of @template.directives.editable
      @editables ||= {}
      @editables[editableName] = undefined


  initializeImages: ->
    @imageCount = @template.directives.count.image
    for imageName of @template.directives.image
      @images ||= {}
      @images[imageName] = undefined


  hasImages: ->
    @imageCount > 0


  hasContainers: ->
    @containers?


  before: (snippetModel) ->
    if snippetModel
      @parentContainer.insertBefore(this, snippetModel)
      this
    else
      @previous


  after: (snippetModel) ->
    if snippetModel
      @parentContainer.insertAfter(this, snippetModel)
      this
    else
      @next


  append: (containerName, snippetModel) ->
    if arguments.length == 1
      snippetModel = containerName
      containerName = templateAttr.defaultValues.container

    @containers[containerName].append(snippetModel)
    this


  prepend: (containerName, snippetModel) ->
    if arguments.length == 1
      snippetModel = containerName
      containerName = templateAttr.defaultValues.container

    @containers[containerName].prepend(snippetModel)
    this


  set: (name, value) ->
    if @editables?.hasOwnProperty(name)
      if @editables[name] != value
        @editables[name] = value
        @snippetTree.contentChanging(this) if @snippetTree
    else if @images?.hasOwnProperty(name)
      if @images[name] != value
        @images[name] = value
        @snippetTree.contentChanging(this) if @snippetTree
    else
      log.error("set error: #{ @identifier } has no content named #{ name }")


  get: (name) ->
    if @editables?.hasOwnProperty(name)
      @editables[name]
    else if @images?.hasOwnProperty(name)
      @images[name]
    else
      log.error("get error: #{ @identifier } has no name named #{ name }")


  copy: ->
    log.warn("SnippetModel#copy() is not implemented yet.")

    # serializing/deserializing should work but needs to get some tests first
    # json = @toJson()
    # json.id = guid.next()
    # SnippetModel.fromJson(json)


  copyWithoutContent: ->
    @template.createModel()


  hasEditables: ->
    @editables?


  # move up (previous)
  up: ->
    @parentContainer.up(this)
    this


  # move down (next)
  down: ->
    @parentContainer.down(this)
    this


  # remove TreeNode from its container and SnippetTree
  remove: ->
    @parentContainer.remove(this)


  # @api private
  destroy: ->
    # todo: move into to renderer

    # remove user interface elements
    @uiInjector.remove() if @uiInjector


  getParent: ->
     @parentContainer?.parentSnippet


  ui: ->
    if not @uiInjector
      @snippetTree.renderer.createInterfaceInjector(this)
    @uiInjector


  # Iterators
  # ---------

  parents: (callback) ->
    snippetModel = this
    while (snippetModel = snippetModel.getParent())
      callback(snippetModel)


  children: (callback) ->
    for name, snippetContainer of @containers
      snippetModel = snippetContainer.first
      while (snippetModel)
        callback(snippetModel)
        snippetModel = snippetModel.next


  descendants: (callback) ->
    for name, snippetContainer of @containers
      snippetModel = snippetContainer.first
      while (snippetModel)
        callback(snippetModel)
        snippetModel.descendants(callback)
        snippetModel = snippetModel.next


  descendantsAndSelf: (callback) ->
    callback(this)
    @descendants(callback)


  # return all descendant containers (including those of this snippetModel)
  descendantContainers: (callback) ->
    @descendantsAndSelf (snippetModel) ->
      for name, snippetContainer of snippetModel.containers
        callback(snippetContainer)


  # return all descendant containers and snippets
  allDescendants: (callback) ->
    @descendantsAndSelf (snippetModel) =>
      callback(snippetModel) if snippetModel != this
      for name, snippetContainer of snippetModel.containers
        callback(snippetContainer)


  childrenAndSelf: (callback) ->
    callback(this)
    @children(callback)


  # Serialization
  # -------------

  toJson: ->

    json =
      id: @id
      identifier: @identifier

    if @hasEditables()
      json.editables = {}
      for name, value of @editables
        json.editables[name] = value

    for name of @images
      json.images ||= {}
      for name, value of @images
        json.images[name] = value

    for name of @containers
      json.containers ||= {}
      json.containers[name] = []

    json


SnippetModel.fromJson = (json, design) ->
  template = design.get(json.identifier)

  assert template,
    "error while deserializing snippet: unknown template identifier '#{ json.identifier }'"

  model = new SnippetModel({ template, id: json.id })
  for editableName, value of json.editables
    assert model.editables.hasOwnProperty(editableName),
      "error while deserializing snippet: unknown editable #{ editableName }"
    model.editables[editableName] = value

  for imageName, value of json.images
    assert model.images.hasOwnProperty(imageName),
      "error while deserializing snippet: unknown image #{ imageName }"
    model.images[imageName] = value

  for containerName, snippetArray of json.containers
    assert model.containers.hasOwnProperty(containerName),
      "error while deserializing snippet: unknown container #{ containerName }"

    if snippetArray
      assert $.isArray(snippetArray),
        "error while deserializing snippet: container is not array #{ containerName }"
      for child in snippetArray
        model.append( containerName, SnippetModel.fromJson(child, design) )

  model