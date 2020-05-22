(* 
==========
Name		: Birthdays
Description	: Add a task to Things for contacts with upcoming birthdays
Author		: Robert van Bregt (https://robertvanbregt.nl/)

Known bugs and features:
  - Task name and notes in Dutch
  - Tested with Things 3.12.3 / MacOS 10.15.4

2020-05-22
  - Initial script.
  
========== 
*)

-- days to look ahead
property AHEAD : 7

-- The project to store the new tasks
property TODOPROJECT : "Relaties"

set cdt to (current date)
set cyr to year of (current date)

tell application "Contacts"
	
	-- get all people with a birth date
	set thePeople to every person whose birth date is not missing value
	if (count of thePeople) = 0 then
		display dialog "No people with birth date."
		return
	end if
	
	set cnt to 0
	repeat with thePerson in thePeople
		
		set bdt to birth date of thePerson
		set byr to year of bdt
		
		-- get this year's birthday from birth date
		set bdy to bdt
		set year of bdy to cyr
		
		if (bdy is greater than cdt) and (bdy is less than (cdt + AHEAD * days)) then
			
			log "Matching birthday: " & short date string of bdy
			
			if (byr = 1604) then -- unknown year
				set age to "zoveelste"
			else
				set age to (cyr - byr) & "e"
			end if
			
			set task_name to "Feliciteren " & (name of thePerson) & " met " & age & " verjaardag"
			
			-- DRY is impossible for phone and email
			-- putting the redundant code in a function raises an error
			
			set theList to (phone of thePerson)
			set allItems to ""
			repeat with theItem in theList
				set theLabel to (label of theItem)
				set theLabel to my removeGarbageFromLabel(theLabel)
				set theValue to (value of theItem)
				set allItems to allItems & theLabel & ": " & theValue & "
"
			end repeat
			set task_phone to allItems
			
			set theList to (email of thePerson)
			set allItems to ""
			repeat with theItem in theList
				set theLabel to (label of theItem)
				set theLabel to my removeGarbageFromLabel(theLabel)
				set theValue to (value of theItem)
				set allItems to allItems & theLabel & ": " & theValue & "
"
			end repeat
			set task_email to allItems
			
			set task_schedule to bdy - 12 * hours
			set task_due to bdy + 8 * hours
			
			set task_note to "---
Van harte gefeliciteerd met je " & age & " verjaardag. Geniet van je dag.
---
" & task_phone & "
" & task_email & "
---"
			
			tell application "Things3"
				set newToDo to make new to do Â
					with properties {name:task_name, due date:task_due, notes:task_note} Â
					at beginning of project TODOPROJECT
				schedule newToDo for task_schedule
			end tell
			
			set cnt to cnt + 1
		end if
		
	end repeat
	
	display notification "Added " & cnt & " birthday reminders to Things."
	
	quit -- contacts
	
end tell

on findAndReplaceInText(theText, theSearchString, theReplacementString)
	set AppleScript's text item delimiters to theSearchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to theReplacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end findAndReplaceInText

on removeGarbageFromLabel(theLabel)
	set theLabel to my findAndReplaceInText(theLabel, "_$!<", "")
	set theLabel to my findAndReplaceInText(theLabel, ">!$_", "")
	return theLabel
end removeGarbageFromLabel

