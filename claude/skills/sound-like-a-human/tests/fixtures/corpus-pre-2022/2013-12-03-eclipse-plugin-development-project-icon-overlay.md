# Eclipse Plugin Development: Project Icon Overlay

If you’re trying to create a Custom Project in Eclipse, you’ll eventually come to read a beautiful blog post over at Hidden Clause that documents quite well how to overlay your icon over Eclipse’s default folder icon to get the icon of your choice.

If you’re default project is an extension of an already existing project (I, for example, wanted a custom Java Project type so I extended Eclipse’s New Java project wizard to get desired effect), the default nature added is that of Java meaning Eclipse adds it’s icon and not the icon you’ve set up. The issue isn’t even in the step you’ve just followed to add the icon. The issue was inadvertenly induced in the last step while adding your custom project nature with code which looks something like this (reference code from Hidden Clause)

This can be remedied easily by ensuring your nature ID is added before that of your predecessors. Eclipse only applies the icon from one nature, not multiple ones. Here’s the code I ended up with

Next up, now to make the icon be used completely and not as a simple overlay..
