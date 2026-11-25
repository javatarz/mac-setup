# WebDevelopment Gotcha: Browsers with Adblock Plus!

Earlier this week, I was maintaining a web-application when I noticed something weird. Some images were not shown on my browser at times. The application dynamically displayed images based on certain conditions using java script and every once in a while, an image would disappear. This only happened to me and would occur on Safari and Chrome.

Looking at the dev console told me that the browser couldn’t set new images to the img tag on the page since it “disappeared”. Investigation showed that the image that the tag disappeared after the image tag tried to show “ad.gif”.

I kept reading this as “aay dee dot gif” (because that’s what it was, based on the application’s context.. that’s certainly why the original, rather unsuspecting developer meant it to be).

What struck me later was that the div was being eaten up by adblock on those browsers and that’s what caused the error. When I tried to access the images directly, they worked. If I embedded them into a HTML page, they wouldn’t.

Conclusion: If you’re a web developer, don’t name images ad.* (or any other image type) because that will cause Adblock Plus to block a rather legitimate image..
