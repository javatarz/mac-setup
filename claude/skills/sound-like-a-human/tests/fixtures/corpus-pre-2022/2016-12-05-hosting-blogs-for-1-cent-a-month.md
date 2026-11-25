# Hosting blogs for 1¢ a month

If you’re a dev and you self host your blog, I’d love to hear why. Why do you self host blogs? For most simple blogs in this day and age, migration to a static site like Jekyll or Octopress is pretty easy. I did this a while back. This can be followed up by asking Amazon S3 to host your website. You can even get cloudflare to front the SSL for free.

Why? S3 is free for the first year. Even post that period, my bills have been <$0.02/month which is a 99.951% reduction in cost.

### Continuous delivery

Snap CI is will integrate with your publically accessible GitHub repositories for free and trigger builds on commit! Connect to your github repository and get it to compile your markdown into html. Deploying to S3 is a piece of cake. Congratulations on having continuous delivery for your blog!

Cloudflare provides the free SSL and Amazon S3 provides the near free hosting. A few cents a month to host your entire website is a good deal!

I’ve been on S3 for a year now and I couldn’t be happier!

** Goodbye Servers, Welcome S3 **
