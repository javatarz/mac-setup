# Glassfish JNDI Custom Resource: Reading Primitives

Custom resources allow you to store server side values that are available to different J2EE applications on your server. This is an extremely useful feature that one should use.

Head on over to the Glassfish admin panel (should be at localhost:4848 for most of you), go to Resources > JNDI > Custom Resources and create a new entry which looks like the following:

It is important to note here that if the name isn’t “value” (exactly), you will not be able to read this value via a InitialContext lookup in your Java code. You will get an exception as follows:

> > > javax.naming.CommunicationException: Communication exception for SerialContext[myEnv={java.naming.factory.initial=com.sun.enterprise.naming.impl.SerialInitContextFactory, java.naming.factory.state=com.sun.corba.ee.impl.presentation.rmi.JNDIStateFactoryImpl, java.naming.factory.url.pkgs=com.sun.enterprise.naming} [Root exception is java.lang.IllegalAccessException: value cannot be null] > ... > Caused by: java.lang.IllegalAccessException: value cannot be null at org.glassfish.resources.custom.factory.PrimitivesAndStringFactory.getObjectInstance(PrimitivesAndStringFactory.java:99) > >

Essentially, the InitialContext code attempts to read a property named “value” by default.

Here is the code you can use to read the constant you’ve added:

> > > new javax.naming.InitialContext().lookup("mailConfig"); > >

If you want to use a JNDI entry in a not so direct way (not name it “value”), you can read it using the following code:

> > > javax.naming.InitialContext c = new javax.naming.InitialContext(); > javax.naming.NamingEnumeration neb = c.listBindings(""); > while (neb.hasMore()) { > javax.naming.Binding b = neb.next(); > if (b.getName().equals("mailConfig")) { > javax.naming.Reference obj = (javax.naming.Reference) b.getObject(); > java.util.Enumeration en = obj.getAll(); > while (en.hasMoreElements()) { > javax.naming.RefAddr ra = en.nextElement(); > System.out.println(ra.getType() + "=" + ra.getContent()); > } > } > } > >

Took me a while to get these code samples working. Doesn’t seem to be clearly documented. Hope this helps someone else :)
