# File list generator v1.1

On a lazy Sunday afternoon when you’ve got nothing better to do, you either write rather useless scripts or update them. I chose to do the latter.

The file list generation script I wrote some time back was mainly to generate a list of movies I have. When I generated a list of all the HD movies I have on disk, I realized, my list was being ruined by loads of sample files which escape the file filter because they are the same extension as the videos themselves. So I decided to write a simple fix to remove all files with “sample” in it. Of course, this is activated by a command line switch which is by default off. The extension list now ignores all images (pngs, jpgs and bmps) so my file list no longer has any screen shots.

Here’s a couple of sample script calls

> C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe _-command_ "**& 'C:\Users\Karun\My Scripts\filelist.ps1**'" "**H:\Movies\HQ**" C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe _-command_ "**& 'C:\Users\Karun\My Scripts\filelist.ps1**'" "**H:\Movies******" "**true**" C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe _-command_ "**& 'C:\Users\Karun\My Scripts\filelist.ps1**'" "**H:\Movies******" "**true**" "**true**"

The first one will call on the script and generate an output. The second will do so recursively. The third one will ignore all files with the word “sample” in them. Simple enough? Go get the code and have fun with it!

If you’re having trouble executing the script, you should consider signing your PowerShell scripts. Scott Hanselman has written a great post on how to do so. Go read it! You could simply Set-ExecutionPolicy to Unrestricted but then you’d be leaving your system open to attacks. Don’t blame anyone but yourself if you run someone else’s unsafe code and screw something up :) You have been warned :)
