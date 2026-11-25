# Recursively delete files from a folder in Windows

This is something one might need to do regularly. I need to because wget often creates multiple index.html@* files despite being set up not to (my GUI for wget might forget configs.. who knows?)

I’m left with a couple of hundred folders with 6 html files each which to me is quite irritating. So here’s a simple command to delete files in Windows recursively.

del /S index.html@*

**Change the “index.html@*” part to anything else you might want. Obviously, wild cards are valid. Have fun and be careful! :)
