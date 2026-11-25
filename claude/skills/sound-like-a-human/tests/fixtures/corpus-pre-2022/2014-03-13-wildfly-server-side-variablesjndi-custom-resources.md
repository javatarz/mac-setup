# WildFly: Server Side Variables/JNDI Custom Resources

As you probably know, Oracle stopped development of Glassfish’s commercial version and in doing so, prompted others to move. News of Glassfish being dead is greatly exaggerated according to some but myself being one who was already not happy with Glassfish’s Open Source version, steps were taken to move to WildFly. So far, the move has been well received in the team except for web based GUI administration panel which isn’t complete. Reliability of the admin panel is higher than Glassfish’s counterpart though and what WildFly’s web admin panel lacks, it’s CLI and Swing based GUI admin panel make up for allowing script writers (such as myself) to come up with automated ways to get things done.

A while back we discussed how you could use JNDI custom resources on Glassfish to set environment variables. Migration for our team meant information setup as environment variables need to be setup again.

## Adding a XA Data Source

Open `Profile` > `Subsystems` > `Datasources` > `XA Datasources` (http://localhost:9990/console/App.html#datasources)

Click the Add Button

Instructions for Step 1/4

- Instructions for Step 2/4

- Instructions for Step 3/4

- Instructions for Step 4/4

- Keep the datasource you just added selected and then click Enable. When asked for confirmation, click Confirm.

## Invoking in code

You can fetch this data in your Java EE code as follows

> > > public static final String PROP_VAL = getServerConfig("datasource-name", "property-name"); > > /** > * Provides access to server configurations specific to JBoss > * > * @param xaDataSource Data Source to be accessed > * @param attributeKey Key to be fetched from the datasource > * @return {@link Object} returned for the key > */ > private static Object getServerConfig(final String xaDataSource, final String attributeKey) { > try { > return ManagementFactory.getPlatformMBeanServer().getAttribute(new ObjectName("jboss.as:subsystem=datasources,xa-data-source=" + xaDataSource + ",xa-datasource-properties=" + attributeKey), "value"); > } catch (MBeanException | AttributeNotFoundException | InstanceNotFoundException | ReflectionException | MalformedObjectNameException ex) { > throw new RuntimeException("Server config for data source \"" + xaDataSource + "\" and attribute key \"" + attributeKey + "\" couldn't be loaded.", ex); > } > } > >

This code is specific to JBoss and it’s derivatives/implementations (such as WildFly). Glassfish’s implementation uses standard JavaX packages and is rather painless to invoke. That’s probably why, desipite killing off the commercial version, Oracle still insists Glassfish is the reference of Java EE for versions 7 and 8 ;)

Calling `new` `InitialContext().lookup(jndiName)` does return a

, again, a JBoss specific class. I’d rather not add any JBoss specific libraries in my projects unless I need to. The closer you are to the Java EE standard, the easier it is to maintain code portability across Java EE servers, especially in our line of work ;)
