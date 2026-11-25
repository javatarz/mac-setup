# Mass downloading Google Drive Files

Has anyone ever shared with you hundreds of Google Drive files instead of sharing the directory? It happened to me today and I noticed Gmail clips the HTML part of the message at 102 KB. Usually Gmail provides a way to download all attachments (Google Drive or otherwise) or the ability to save them on your Google Drive from where you can mass download them. If the email is clipped, you can only save a subset of these files into your Google Drive so no mass downloads. Bummer.

It’s simple enough to fix with some Scala magic. First you should save the email source as email.html. This file can then be read line by line to find any google docs links along with the file name. In my case the files were named “File - 1.JPG”. Next update the file saving location (for me it was “dl/File 1.jpg” for which I created the folder dl). Assuming your regular expressions are correct, you’re good to go!

Yes, this is a quick hack and can be improved for readability (such as extracting the regular expression, download link and file read and save locations) but for a quick hack that seems unnecessary.
