# Reducing Maven Package times due to resource copying

I once worked on a web application with a 250+MB code base. This consisted of 200,000 images. For every development cycle, you had to compile and deploy the code on the server which was painful to say the least. The size wasn’t the problem as much as the number of resources. The code took less than 20 seconds to compile.

We figured that compilations overwriting class files were OK but having to edit any resource just took too long. In such cases, you can use maven’s process-resources plugin to ask maven to only copy the new resources to your target directory.

This is significantly faster. Package times went down from 6 minutes to 18 seconds. Of course, a SSD would have helped but looking at the difference, it’s well worth the effort :)

Go try it out!
