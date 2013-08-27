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
  isDragging = false

  currentPosition = ->
    pos = parent.position().left
    if opts.includeParentWidth
      pos += parent.width()
    return pos

  currentPositionRelativeToElement = (event) ->
    event.pageX - parent.offset().left

  handle.on 'mousedown', (downEvent) ->
    return if isDragging
    downEvent.preventDefault()
    
    min = if typeof offsetMin is 'function' then offsetMin() else offsetMin
    max = if typeof offsetMax is 'function' then offsetMax() else offsetMax

    percentOfXVal = (x) -> (x - min) / (max - min)

    handleStartX = currentPosition()
    startTime = Date.now()
    hasDragged = false
    isDragging = true

    drag = (dragEvent) ->
      if !hasDragged
        position = percentOfXVal(currentPosition())
        relativePosition = currentPositionRelativeToElement(dragEvent)
        emitter.emit('dragStart', position, relativePosition)
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

      position = percentOfXVal(potentialX)
      relativePosition = currentPositionRelativeToElement(dragEvent)
      emitter.emit('drag', position, relativePosition)

    complete = (event) ->
      isDragging = false
      page.off('mousemove', drag)
      page.off('mouseup', complete)
      page.off('mouseout', complete)
      if hasDragged
        position = percentOfXVal(currentPosition())
        relativePosition = currentPositionRelativeToElement(event)
        emitter.emit('dragFinish', position, relativePosition)
      else if Date.now() - startTime < 500
        emitter.emit('click')

    page.on('mousemove', drag)
    page.on('mouseup', complete)
    page.on('mouseout', complete)

  return emitter
