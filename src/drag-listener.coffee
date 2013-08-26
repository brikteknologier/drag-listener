EventEmitter = require('events').EventEmitter
module.exports = (parent, handle, offsetMin, offsetMax, opts) ->
  if typeof handle isnt 'object'
    offsetMax = offsetMin
    offsetMin = handle
    handle = parent

  opts ?= {}

  handle = $(handle)
  parent = $(parent)
  page = $('body')
  emitter = new EventEmitter()

  currentPosition = ->
    pos = parent.position().left
    if opts.includeParentWidth
      pos += parent.width()
    return pos

  handle.on 'mousedown', (downEvent) ->
    handleStartX = currentPosition()
    
    min = if typeof offsetMin is 'function' then offsetMin() else offsetMin
    max = if typeof offsetMax is 'function' then offsetMax() else offsetMax

    downEvent.preventDefault()

    percentOfXVal = (x) -> (x - min) / (max - min)

    startTime = Date.now()
    hasDragged = false

    drag = (dragEvent) ->
      if !hasDragged
        emitter.emit('dragStart', percentOfXVal(currentPosition()))
        hasDragged = true

      offsetX = dragEvent.pageX - downEvent.pageX
      currentX = currentPosition()
      potentialX = handleStartX + offsetX

      if min > potentialX
        return if currentX is min
        potentialX = min
      else if max < potentialX
        return if currentX is max
        potentialX = max
      emitter.emit('drag', percentOfXVal(potentialX))

    complete = ->
      page.off('mousemove', drag)
      page.off('mouseup', complete)
      if hasDragged
        emitter.emit('dragFinish', percentOfXVal(currentPosition()))
      else if Date.now() - startTime < 500
        emitter.emit('click')

    page.on('mousemove', drag)
    page.on('mouseup', complete)

  return emitter
