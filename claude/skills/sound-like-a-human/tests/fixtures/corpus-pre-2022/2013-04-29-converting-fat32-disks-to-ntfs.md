# Converting FAT32 disks to NTFS

There used to be a slightly long way to do this earlier but I found a simple one line command to do it. It is probably old but it’s one I didn’t know of.

> convert L: /fs:NTFS

This converts L: to NTFS without removing any data from the drive. This process, all in all, requires less than 3 seconds.
