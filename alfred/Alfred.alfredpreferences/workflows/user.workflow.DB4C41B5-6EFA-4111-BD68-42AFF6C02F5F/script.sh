#!/bin/bash

SEARCHDIR="$1"
QUERY="$2"

icon(){
	appname=$(basename "$1")
	appname=${appname%%.*}
	appname=$(echo "$appname" | sed 's/-/ /g' | sed 's/\./ /g' | sed 's/_/ /g' | sed 's/[0-9]*//g' | sed 's/  */ /g' | sed 's/ *$//g')
	
	yesis=$(find /Applications -maxdepth 2 | grep -i "$appname" | grep ".app" | head -1)
	
	if [[ -z $yesis ]];then
		echo "$1"
	else
		echo "$yesis"
	fi
}

if [[ -z "$SEARCHDIR" ]]; then
	SEARCHDIR="$HOME/Downloads"
fi

TABELA=$(find "$SEARCHDIR" | egrep -i '\.zip$|\.app$|\.pkg$|\.dmg$' | grep -i "$QUERY")

echo '<?xml version="1.0"?><items>'
while IFS= read -r line
do
FILE=$(basename "$line")
KBSIZE=$(du -ks "$line" | awk '{print $1}')
SIZE=$(echo "scale=2;x=($KBSIZE/1024); if (x<1) print 0; x" | bc)
ADDED=$(stat "$line" | awk '{print $22, $21, $24}' | sed 's|\"||g')
SETICON=$(icon "$line")
echo '<item>
	<arg>'$line'</arg>
	<title>Install: '$FILE'</title>
	<subtitle>Size: '$SIZE' MB | Date Added: '$ADDED' | '$line'</subtitle>
	<icon type="fileicon">'$SETICON'</icon>
</item>'
done <<< "$TABELA"
echo '</items>'