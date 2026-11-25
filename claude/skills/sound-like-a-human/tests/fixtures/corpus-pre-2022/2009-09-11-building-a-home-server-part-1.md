# Building a Home Server: Part 1

The first question in your head would be “Why the world do I need a Home Server?”

Good question. I’d like to ask you a couple of things. Do you have multiple machines in your house? Do you ever feel like you should have centralized storage in your house? Do you have old hardware simply lying around the house waiting to be tinkered with? Do you like playing with your machines?

If you said yes to (most) of the above questions, having a Home Server could help you :) It can handle not only centralized storage of media and documents but also backups. Have you ever needed a file from computer x in your house and found it was shut down after being used by a family member? Well, you wouldn’t have this issue if you had a central server. People could go around switching off their machines all they want as long as you have the file you want on your Storage Server.

Lets get into it then. From now, I’ll walk you through how to make your old machine into a Network Attached Server (NAS).

#### 1) Hardware

Any hardware is fine for a Home Server. The main purpose (at least in this case) is central file storage for all devices and this doesn’t require much resources on the processing side. Lets start with the specifications of this machine:

Now that is a pretty good processor for this purpose, I agree. You should be fine using a Celeron or even a Pentium 3.

#### 2) Operating System

The next important question is the choice of operating systems. To answer these, you need to look at your usage of the server.

I really wanted to run Windows Server 2008 R2 but since this processor is an x86 one, I couldn’t. Windows Server 2008 gave me sluggish performance so I gave it the axe by the end of the night. I didn’t want to try Windows Server 2003 since it was quite old. More importantly, I found Windows Home Server by that time, a product made specifically for Home Servers and it was made using Windows Server 2003 as base ;)

I must say, Windows Home Server (WHS) really has the most horrible OS installer I have seen on a Windows operating system. When it was all set and done, I ran updates and everything but whilst using it, I really wasn’t impressed :( Don’t get me wrong, it is pretty darn good but India is a place where Windows Media Center doesn’t give you everything that it does in countries like the United States. It surely has potential and may be some day, it will even make its way on to my server. But for now, I can’t do so especially since I don’t have a IDE drive greater than 80GB that can run the WHS. If you read my system specs correctly, you’d have noticed this old machine has only one IDE port, which I’m reserving for at least a 1TB drive.

I started considering Linux! (yes, I said Linux). I considered using Ubuntu/Xubuntu on the machine, as an obvious choice for any Linux newbie. For those who don’t know the difference between the two, Ubuntu uses Gnome for its UI and Xubuntu uses KDE. Other than that, they are identical. If you don’t have a choice towards either, I’d tell you to go for Xubuntu if you’ve got an older machine (or just like a machine with free resources). KDE requires lesser resources and should run almost anywhere. I saw this pretty detailed article about setting up a home server on Xubuntu that you should check out if Ubuntu/Xubuntu is your OS of choice.

Then comes the final choice, FreeNAS. If you want a NAS, you can’t go wrong with FreeNAS. Weighing in at around 70 megabytes for a live CD with installer, its a really good choice. It is built on FreeBSD and I must say, its pretty extensive. Just have a look at FreeNAS’ list of features; its insane!

I’d suggest you go with FreeNAS if you just want to use your server as a NAS. It uses Samba to give you CIFS (in non technical jargon, it allows you to share files in a network like Windows does) and provides support for protocols like FTP, SSH and iTunes. It can be extended to support XMBC and SlimServer. It also allows you to host a web server using lighttpd and even supports UPS, SMART, ZFS, RAID and most NICs and IDE/SATA disk controllers. If there is anything that you need to do that you can’t see on this list and can’t manage to get FreeNAS to do (I believe it will run almost anything which runs on FreeBSD) then you can move to Ubuntu/Xubuntu. You could even run ASP .NET pages off Linux web servers (haven’t tried it yet) with the limited support that Mono provides :)

Part 2 of the tutorial will have the basic setup for FreeNAS and how to get CIFS working. Subsequent parts will talk about setting up FTP, SSH and Web Server with MySQL and phpmyadmin. You never know, if I can get it to execute ASP .NET as well, you guys will be the first to know! ;)
