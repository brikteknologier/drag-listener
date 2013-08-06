EventEmitter = require('events').EventEmitter
module.exports = (parent, handle, offsetMin, offsetMax) ->
  if typeof handle isnt 'object'
    offsetMax = offsetMin
    offsetMin = handle
    handle = parent

  handle = $(handle)
  parent = $(parent)
  page = $('body')
  emitter = new EventEmitter()

  handle.on 'mousedown', (downEvent) ->
    handleStartX = parent.position().left

    min = if typeof offsetMin is 'function' then offsetMin() else offsetMin
    max = if typeof offsetMax is 'function' then offsetMax() else offsetMax

    downEvent.preventDefault()

    percentOfXVal = (x) -> (x - min) / (max - min)

    drag = (dragEvent) ->
      offsetX = dragEvent.pageX - downEvent.pageX
      currentX = parent.position().left
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
      emitter.emit('dragFinish', percentOfXVal(parent.position().left))

    emitter.emit('dragStart', percentOfXVal(parent.position().left))
    page.on('mousemove', drag)
    page.on('mouseup', complete)

  return emitter
