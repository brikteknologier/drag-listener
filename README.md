# drag-listener

Listen to horizontal drag events on a dom element. *drag-listener* will not 
actually move the element around for you, it will just notify you of the user's 
attempt to drag the element.

## install

```
npm install drag-listener
```

## environmental requirements

*drag-listener* has some fairly strict environmental requirements in that it
must be used in conjunction with browserify (hence the npm distribution). It
also expects `$` in the global scope to reference jQuery at runtime.

## usage

`listen(element, [handle,] offsetMin, offsetMax, [opts])`

Start listening for drag events on an element. Returns an EventEmitter that 
emits the events in the *events* section below.

* `element` the element that will have its position measured to return a value
  for the drag event. For more details, on how this is measured, see the `drag`
  event below.
* `handle` (optional) - the handle of the draggable element, this is the thing
  that user clicks on to start dragging. Defaults to `element`.
* `offsetMin` the minimum bound of the draggable element, relative to its parent.
  Can also be passed as a function that returns a number (the function is called
  at the start of each drag to determine the minimum bound for that drag)
* `offsetMax` the maximum bound of the draggable element, relative to its parent.
  Can also be passed as a function that returns a number (the function is called
  at the start of each drag to determine the maximum bound for that drag)
* `opts` (optional) a set of options, specified below

### options

* `includeWidth` (default = false) if set to true, include the width of the 
  parent when calculating its current position.
* `stopPropagation` (default = true) if set to true, don't propagate the initial
  mousedown event that initiates a drag
* `shouldDrag` (default = `function(){return true}`). a function that is called
  when a drag is initiated, determining if the drag should be ignored. Shall
  return true or false.
* `movementThreshold` (default = 1). The minimum distance to move before a drag
  is triggered.
* `timeThreshold` (default = 100). The minimum time before a drag is triggered
  (in ms).
* `requireBothThresholds` (default = false). If set to true, both time and
  position thresholds must be satisfied before a drag is triggered.

### events

* `dragStart` - emitted when the user initiates a drag (when the handle receives
  a mousedown and a mousemove event). Passes one argument, a number between 0.0
  and 1.0 that indicates where the element is located at the start of the drag.
* `drag` - emitted when the user drags the element (fired for every mousemove 
  event received after the handle has received a mousedown event, but before it 
  has received a mouseup event). Passes one argument, a number between 0.0 and
  1.0 that indicates where the user has dragged the element between the 
  `offsetMin` and `offsetMax` bounds.
* `dragFinish` - emitted when the user finishes a drag (when the handle receives
  a mouseup event). Passes one argument, a number between 0.0 and 1.0 that 
  indicates where the element is located at the end of the drag.
* `click` - emitted when a mousedown and a mouseup event is received in the space
  of 500ms, and no mousemove events are received.
