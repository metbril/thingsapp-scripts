(*

Purpose: Schedule selected todos for tomorrow

2020-05-20:
  - Initial version

*)
tell application "Things3"
	set theToDos to selected to dos
	repeat with theToDo in theToDos
		schedule theToDo for (current date) + (1 * days)
	end repeat
end tell