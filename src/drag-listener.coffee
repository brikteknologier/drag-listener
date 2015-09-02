EventEmitter = require('events').EventEmitter
module.exports = (parent, handle, offsetMin, offsetMax, opts) ->
  if typeof handle isnt 'object'
    opts = offsetMax
    offsetMax = offsetMin
    offsetMin = handle
    handle = parent

  opts ?= {}
  if not opts.stopPropagation?
    opts.stopPropagation = true
  if not opts.shouldDrag or typeof opts.shouldDrag isnt 'function'
    opts.shouldDrag = -> true

  canTouch = !!('ontouchstart' of window)
  eventName = (action) ->
    if canTouch
      switch action
        when "start" then return "touchstart mousedown"
        when "move" then return "touchmove mousemove"
        when "finish" then return "touchcancel mouseup mouseleave touchend"
        else return undefined
    else
      switch action
        when "start" then return "mousedown"
        when "move" then return "mousemove"
        when "finish" then return "mouseup mouseleave"
        else return undefined

  coordinates = (e) ->
    if e.originalEvent instanceof MouseEvent
      return { x: e.pageX, y: e.pageY }
    else if e.originalEvent instanceof TouchEvent
      return { x: e.originalEvent?.touches[0]?.pageX, y: e.originalEvent?.touches[0]?.pageY }
    else
      return undefined

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
    coordinates(event).x - parent.offset().left

  handle.on eventName('start'), (downEvent) ->
    return if isDragging or !opts.shouldDrag()
    downEvent.preventDefault()
    downEvent.stopPropagation() if opts.stopPropagation
    
    min = if typeof offsetMin is 'function' then offsetMin() else offsetMin
    max = if typeof offsetMax is 'function' then offsetMax() else offsetMax

    percentOfXVal = (x) -> (x - min) / (max - min)

    handleStartX = currentPosition()
    startTime = Date.now()
    hasDragged = false
    isDragging = true
    downCoords = coordinates(downEvent)

    drag = (dragEvent) ->
      if !hasDragged
        position = percentOfXVal(currentPosition())
        relativePosition = currentPositionRelativeToElement(dragEvent)
        emitter.emit('dragStart', position, relativePosition)
        hasDragged = true

      dragCoords = coordinates(dragEvent)
      offsetX = dragCoords.x - downCoords.x
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
      page.off(eventName('move'), drag)
      page.off(eventName('finish'), complete)
      if hasDragged
        position = percentOfXVal(currentPosition())
        relativePosition = currentPositionRelativeToElement(event)
        emitter.emit('dragFinish', position, relativePosition)
      else if Date.now() - startTime < 500
        emitter.emit('click')

    page.on(eventName('move'), drag)
    page.on(eventName('finish'), complete)

  return emitter
