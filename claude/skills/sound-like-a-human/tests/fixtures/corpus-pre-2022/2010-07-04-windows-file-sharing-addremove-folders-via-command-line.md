# Windows File Sharing: Add/Remove folders via Command Line

Your first thought on reading this probably is “Why in the world would I need to do that?” Well, I would have thought of it the same way a week back. But it seems some times, Windows does not want to give access to certain features such as Advanced File Sharing options. It states that the administrator on my machine has disallowed this operation. Guess what? I’m the only administrator on this machine! Since I was unable to find the option to get that feature working, I decided to resort to some good old Command Line usage :)

To remove a file/folder from share and type the following command in an elevated instance of command prompt:

> net share __ /delete</blockquote> To add a file/folder to share and type the following command in an elevated instance of command prompt:

> net share __=__</blockquote> An example of an add and delete command would be as follows

> net share "Completed Downloads"="D:\Completed Downloads" net share "Completed Downloads" /delete

> At times, I was not required to use an elevated command prompt instance but if you get message stating "Access Denied", you should run the command after elevation. To do so, type out "Command Prompt" in your start menu and then use the right click > Run as administrator option or you could simply use Shift+Enter to do the same :) Simple enough, right? ;)
