# Clean File List Generation with PowerShell Script

I have a whole load of movies that I’d like to generate a list of. I considered writing a batch script but it didn’t really do something I needed. I ended up writing my first regular use (non test) PowerScript and here’s how.

My first requirement was to list all my 1080p movies and for the list to leave out all the subtitles. So I was looking for a function to list files (dir in command prompt did that :)) and then remove files by extension. As it turned out, I could list files of a certain extension but not leave out files by extensions. Finally, I had to write the result to file (simple enough to do in command prompt. Use the > operator to direct output of the previous command to a file) So, a quick fix would be to use something like

> dir *.avi *.mp4 *.mpg *.mpeg *.mkv /B /O N

For sub-folders, you can use tree and fiddle around the options but lets face it, as programmers, we want better solutions.

Since the launch of Windows 7, Microsoft has shipped PowerShell with the OS making it much more “main stream”. I had played around with PowerShell a couple of years ago when version 1 came out but I thought it was time that I actually made a regular use script.

The core of the script is using get-childitem to get all files and folders in a directory. From there, you can make it go recursive (and look inside sub directories) with a -recurse switch. Little bit of piping allows you to eliminate results you don’t need. For this, I wrote a simple function.

> function fileCheck([string]$extention, [string]$attributes) { # list of rejected extentions $exts = ".srt",".sub",".idx",".txt",".lnk" return $exts -notcontains $extention -and $attributes -ne "Directory" }

As you’ve probably figured out, this function ignores those file extensions and directories as well from our final file list.

Once you have the list, you can either use $object.Name for full name (ie file name with extension) or $object.BareName for only the file name. On reading the source of my script, you’ll see I’m using both and also writing a count of the number of files in a file named list.txt. The first part of the file is a human readable list for your consumption using new lines for separation. The second is a single line output of all files using commas for separation and containing a file count at the end. The latter is simply for copy pasting into chats (like IRC) where you can’t spam with a huge multi-line list.

I went on then to add more code to handle command line inputs so that you can make shortcuts from folders and call the script. I have attached a couple of sample script calls

> C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe _-command_ "**& 'C:\Users\Karun\My Scripts\filelist.ps1**'" "**H:\Movies\HQ**" C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe _-command_ "**& 'C:\Users\Karun\My Scripts\filelist.ps1**'" "**H:\Movies**" "**true**"

The first one will call on the script and generate an output. The second will do so recursively. Simple enough? Go get the code and have fun with it!

If you’re having trouble executing the script, you should consider signing your PowerShell scripts. Scott Hanselman has written a great post on how to do so. Go read it! You could simply Set-ExecutionPolicy to Unrestricted but then you’d be leaving your system open to attacks. Don’t blame anyone but yourself if you run someone else’s unsafe code and screw something up :) You have been warned :)
