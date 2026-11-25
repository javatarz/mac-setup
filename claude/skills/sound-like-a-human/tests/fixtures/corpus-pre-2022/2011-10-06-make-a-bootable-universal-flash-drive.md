# Make a bootable Universal Flash Drive

This is a really old trick for Universal Flash Drives (UFDs) and I’ve been using it for years. I just thought I should document the steps so it’s available as quick reference for me :)

Insert your UFD and make sure all your data is backed up because we’re going to format it.

Run command prompt

Open diskpart (will ask for elevation)

Type “list disk”

find what disk is your USB based on the size. Mine is number 3.

type “select disk 3” (where 3 is the number that the system associates with my flash drive)

type “clean”

type “create partition primary”

type “select partition 1”

type “active”

type “format fs=ntfs”. Might take some time based on the size of your drive

type “assign”. This gives your drive a letter on the system.

type “exit”. Closes diskpart.

For step 11, you might get away with “format fs=ntfs quick” as well since full format takes forever. Now your UFD is ready for installing Windows, Linux or anything else you want. You can now even boot an operating system off it ;)
