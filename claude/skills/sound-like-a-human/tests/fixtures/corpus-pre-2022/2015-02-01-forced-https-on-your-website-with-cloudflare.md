# Forced HTTPs on your website with CloudFlare

I’m a supporter of the HTTPS everywhere movement by the EFF. They advocate users use (all) websites with HTTPS for extra security. This means everyone should probably fork out a few dollars to get their own certificates. Unless you’re buying a domain at NameCheap (in which case they tend to throw in a SSL certificate for the first year), you’d have to shell out $8-$12 to get one.

Side note, I recommend every user have HTTPS everywhere installed on every browser.

Though it’s not perfect, you can get a SSL for your website for free.

### Why do I need SSL?

The communication between you and a website looks something like this without SSL.

It’s prone to a Man in the middle attack. This could be done by your neighbour tapping into the line, your ISP or someone half way across the world listening in on the server you request data from.

### What would you have me do?

#### Move your domain to CloudFlare

CloudFlare is a CDN that provides you with additional security by analysing requests using crowd sourced data over hundreds and thousands of websites. Add your domain to CloudFlare and ask your DNS provider to send all requests to the CloudFlare servers. Once the setup is complete, your data will be sent to your server via CloudFlare. It ensures your IP is not exposed outside there by providing it with some amount of Denial of Service attack prevention since your IP is not directly exposed and it is CloudFlare’s job to handle in coming Denial of Service attacks (once set up).

Users must note that the move to CloudFlare means you can’t SSH to your machine anymore because they do not forward the port. You can create a subdomain that doesn’t route traffic through CloudFlare. That makes it easier to SSH/FTP into the box but provides a way for attackers to access your machine bypassing CloudFlare’s security. Alternately you can add a vhost entry on your machine ensuring you can connect with ease but this won’t help you if you would like to connect from some other machine. You could just remember the IP if you’re a pro :P The choice is yours!

#### Enable CloudFlare’s Universal SSL

CloudFlare provides a universal SSL for all domains routed through their service. As long as you trust CloudFlare’s SSL keys not to be leaked (if they do, bigger businesses would have a problem way before your website does).

This feature is available for free to all users. I recommend using at least the Flexible SSL which requires no further setup. Turn it on and you can hit your website using https. For now, choose Flexible SSL.

#### Force HTTPS

Ideally you want HTTPS to be an option your users choose. You’d want to at least make it a default. If people don’t know, they wouldn’t move to using it. I see no reason why browsers these days won’t be showing your content correctly if they are in HTTPS so I recommend having it on as a default.

If you run a blog or website where there are no “users” but readers, it’s hard to let them choose their HTTPS settings. If you haven’t noticed already, you are accessing this website using HTTPS. Welcome to the dark side.

No need to write a htaccess or similar config on your server. Go to CloudFlare and create a HTTP rule for your base domain asking for a redirect to HTTPS.

### Are we there yet?

Not quite.

The communication between you and CloudFlare is secure. The communication between CloudFlare and your server isn’t.

#### Adding SSL for CloudFlare-Server communication

You can create a self signed certificate on your server. For any Unix based server you can use OpenSSL to generate it. The internet is filled with tutorials galore. Most of them will have information on how to install with your web server of choice (for example apache or nginx).

Once you’re done, go back to the CloudFlare settings for your domain and change the option to Full SSL.

## Potential Flaws?

You’re pretty secure if you ask me. The vulnerable points in the system are the CloudFlare server and your server. Ideally, CloudFlare protects the identity of the server ensuring all requests go through their servers which are meant to protect you from attacks. Lets assume CloudFlare’s private key isn’t compromised. This means the only way to decrypt requests to your server is by getting the private key off your machine and listening into requests to your server.

Another potential area of concern is the fact that the CloudFlare to server communication is prone to a Man in the middle attack since CloudFlare doesn’t verify the signature from from the server for free accounts. For this, you would need to move to a CloudFlare Pro account which at $20/month (as of the writing of this post) is significantly more expensive than purchasing your own SSL certificate end to end. Of course, we don’t use CloudFlare just for the free SSL but the CDN and crowd sourced security it provides. This is hands down the most serious vulnerability in the system I can spot.

You’re better off than where you started and all this for free! Want more? Shell out money to a CA to get your very own certificate :)

*[CA]: Certificate Authority
