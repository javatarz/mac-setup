#!/bin/bash

QUERY="$1"
APP=$(basename "$QUERY")
APPNAME="${APP%%.*}"
APPNM="${APPNAME// /-}"
EXT="${APP##*.}"

OPENAGAIN=0

ZIPTMP="$HOME/Downloads/$APPNM"

notification(){
	osascript -e 'tell application "Alfred 2" to run trigger "postnotification" in workflow "com.mcskrzypczak.install" with argument "'"$1"'"'
}

isrunning(){
	CHECK=$(ps -A | grep -i "$1" | head -1 | awk -F'/' '{print $3}' | sed 's|.app||g')
	
if [[ "$1" == "$CHECK" ]]; then
	QUESTION=$(osascript -e 'set answer to the button returned of (display dialog "The application '"$APPNAME"' is running. You need to close it before installing update.\n\nWould you like to quit it now?" buttons {"Yes", "No"} default button 1 with icon caution with title "Install App")')

	if [[ "$QUESTION" == "Yes" ]]; then
		killall "$CHECK"
		OPENAGAIN=1
	fi
fi
}

isapp(){
	rsync --delete -a -v "$1" /Applications > /dev/null
	pid=$!
	while ps -p $pid > /dev/null;
	do
		sleep 1
	done
}

checkzip(){
	unzip "$1" -d "$ZIPTMP" > /dev/null
	toinstall=$(ls -a "$ZIPTMP" | egrep -i '\.zip$|\.app$|\.pkg$|\.dmg$'  | grep -v -i "uninstall" | head -1)
	EXT="${toinstall##*.}"
	APPNAME="${toinstall%%.*}"
	
	count=1
	
	while [ $count -gt 0 ];
	do
		if [ "$EXT" == "app" ]; then
			isrunning "$APPNAME"
			isapp "$ZIPTMP/$toinstall"
			notification "$APPNM has been successfuly installed!"
			count=0
		elif [ "$EXT" == "pkg" ]; then
			open "$ZIPTMP/$toinstall"
			pid=$(ps -A | grep -i "installer" | head -1 | awk '{print $1}')
			while ps -p $pid > /dev/null;
			do
				sleep 1
			done
			notification "$APPNM has been successfuly installed!"
			count=0
		elif [ "$EXT" == "dmg" ]; then
			checkdmg "$ZIPTMP/$toinstall"
		fi
	done
	
	rm -rf "$ZIPTMP"
}

checkdmg(){
	notification "Installing application, please wait…"
	CONVERT=$(hdiutil convert -quiet "$1" -format UDTO -o /tmp/installdisk)
	MOUNTPOINT=$(echo $(hdiutil attach -noverify -nobrowse /tmp/installdisk.cdr | tail -1 | awk '{$1=$2="";print $0}'))
	toinstall=$(ls -a "$MOUNTPOINT" | egrep -i '\.zip$|\.app$|\.pkg$|\.dmg$'  | grep -v -i "uninstall" | head -1)
	EXT="${toinstall##*.}"
	APPNAME="${toinstall%%.*}"
	
	if [ "$EXT" == "app" ]; then
		isrunning "$APPNAME"
		isapp "$MOUNTPOINT/$toinstall"
		notification "$APPNM has been successfuly installed!"
	elif [ "$EXT" == "pkg" ]; then
		open "$MOUNTPOINT/$toinstall"
		pid=$(ps -A | grep -i "installer" | head -1 | awk '{print $1}')
		while ps -p $pid > /dev/null;
		do
			sleep 1
		done
		notification "$APPNM has been successfuly installed!"
	fi
	
	hdiutil detach "$MOUNTPOINT" > /dev/null
	rm /tmp/installdisk.cdr
	
	if [ $count = 1 ]; then
		count=0
	fi
}

delete(){
osascript <<EOF

set the_path to "$QUERY"
set the_folder to (POSIX file the_path) as alias

set answer to the button returned of (display dialog "The process of copying / installing app has ended.\n\nWould you like to remove source file now?" buttons {"Yes", "No"} default button 2 with icon caution with title "Install App")

if (answer = "Yes") then
	tell application "Finder"
		move the_folder to trash
	end tell
end if
EOF
}

if [ "$EXT" == "app" ]; then
	isrunning "$APPNAME"
	isapp "$QUERY"
	notification "$APPNM has been successfuly installed!"
	rm -rf "$QUERY"
elif [ "$EXT" == "pkg" ]; then
	open "$QUERY"
	pid=$(ps -A | grep -i "installer" | head -1 | awk '{print $1}')
	while ps -p $pid > /dev/null;
	do
		sleep 1
	done
	notification "$APPNM has been successfuly installed!"
	delete
elif [ "$EXT" == "zip" ]; then
	checkzip "$QUERY"
	delete
elif [ "$EXT" == "dmg" ]; then
	checkdmg "$QUERY"
	delete
fi

if [ $OPENAGAIN = 1 ]; then
	open "/Applications/$CHECK.app"
fi