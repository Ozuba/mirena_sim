extends Node
## Logger lmao pretty self explanatory

var _display: LoggingDisplay = null

func _set_display(display: LoggingDisplay):
	self._display = display

func disp_std(what: Array):
	if self._display == null: return
	self._display._disp_std(what)

func disp_debug(what: Array):
	if self._display == null: return
	self._display._disp_debug(what)

func disp_warn(what: Array):
	if self._display == null: return
	self._display._disp_warn(what)	

func disp_error(what: Array):
	if self._display == null: return
	self._display._disp_error(what)
