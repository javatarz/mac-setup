# Getting Sony Vaio VGN-CR35G/R's Ricoh MotionEye USB r5u870 Web Camera working on Ubuntu 10.10 Maverick Meerkat

It’s been a while since my laptop (a Sony Vaio VGN-CR35G/R) has been running Ubuntu and yesterday, I updated my OS to the release candidate for Ubuntu’s latest OS (due to release in 7 days time; 10-10-2010 ;)) 10.10 codenamed Maverick Meerkat. It’s been irritating me for a while that I didn’t have support for the inbuilt web camera for this laptop (which is one of Ricoh’s MotionEye USB cameras; model r5u870).

I had tried looking for drivers a couple of times prior to this but always failed. Finally, I found a package that supports Ricoh’s r5u87x series and the installation couldn’t be simpler. Simply get this one package and you should be set!

It should be all smooth sailing from there on out. You can go ahead and test your camera on Skype or guvcview. I do suggest you try the latter since it will allow you to play around a bit with some settings :)

Do note that every time you reboot, you would have to reload the firmware into the camera so you should probably make a bash script with the last line in it ;)

I personally put this script in an executable folder and made this script executable so that I can access it quickly from anywhere. After boot, if I do need my web cam, I simply load this script up, confirm with a “Y” and I’m all ready to use the webcam ;)

This should work on prior versions of Ubuntu as well so feel free to try this out on Ubuntu 10.04 or anything prior to that :) If the web camera on your Sony Vaio is not working, installing the r5u87x package totally seems worth the (rather minimal) effort ;)
