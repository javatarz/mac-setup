# Lombok usage in large enterprises

### Verbosity of Java

Java is a verbose language. No one disputes it.

Despite the clunky nature of the language syntax, it still is the language of choice in most enterprises. If you work in the services industry or are a technology consultant, chances are that you have to work with Java on a regular basis.

If you’re also a fan of functional programming language and have worked any modern programming language, you’ll recognize that Java’s syntax hinders your productivity because of the large amounts of boilerplate the language will generate. While newer JVM based lanaguages like Kotlin solve these problems in different ways, the open source community created Project Lombok to provide similar syntactic sugar in the world’s most popular enterprise programming language.

### What is Lombok?

Lombok is a Java dependency that uses Java annotations to generate byte code straight into the class files during the compilation phase there by allowing the boilerplate code from your codebase to be significantly reduced.

An example from the Software Engineering Trends post from Jan 2010 shows

would generate the same code as

#### The good

You shouldn’t have to write code that can be generated automatically. Of course, modern IDEs will do this for you with a few clicks of the keyboard

We’re trying to optimize more than a few clicks though. Have a look at the equals method below:

Is this a standard equals method (one where every field in the class is checked for equality)? Did we skip a field? Did we do a non standard check on one of the fields? Unless you go through the method line by line, there is no way to know.

Generating code saves you the hassle of checking. If there is an annotation, you know the what the implementation will be (assuming you know how the framework works). If there’s code, chances are that it’s a non-standard implementation (or someone made a mistake).

#### The bad

If you wish to check the generated code, you need an IDE that decompiles byte code or a tool that does the same.

If something’s wonky, debugging the issue might not be straight forward.

#### The downright ugly

Modern IDEs like IntelliJ are built for refactoring. One of the most common refactoring options is the option to Change Signature. It’s an extremely useful option that allows you to reorder method (or constructor) parameters and the IDE takes care of the appropriate changes throughout the codebase.

The order of the constructor parameters in a lombok-fied class is the order in which the parameters are declared. Changing this order changes the constructor signature.

For a class with different parameter types, this is not a problem. Refactoring the following class

to the following signature

is not a problem. The usage of the constructor will fail to compile and provide feedback.

If you have primitive types in your lombok-fied class, you have a problem. Refactoring the following class

to the following signature

will provide no feedback. The code will compile and set `employeeId`s to `firstName`s, `firstName`s to `lastName`s and `lastName`s to `employeeId`s. If you don’t have tests on the behavior of the `Person` class, you won’t notice this issue until it’s too late. Hopefully, you don’t have tests for a data container with no behavior.

### Where is Lombok appropriate?

- Do you have a project where you have a strict set of contributors?

- because you’ll have to walk them through the rules of appropriate usage of lombok

- Do your contributors understand Lombok well and how it works?

- because you will have unexpected defects due to refactoring if they don’t

- Do your contributors understand how to properly unit test and do they understand the automation test pyramid?

- appropriate high level testing could catch functional defects. you don’t want unit tests checking constructors and getters

- Do you have strict code quality control?

- without a way to check for inappropriate usage of lombok, defects can very easily creep in

- Is the team willing to invest time and effort into training new team members about Lombok and potential downsides?

- your learnings have to be passed to every future member of the codebase

- Do most of your models use value objects and avoid primitives?

- because reordering non-primitive fields will lead to compile exceptions providing feedback

If your team can answer yes to all of the above, you should use Lombok.

I must admit, most large teams can’t answer yes to all of the questions. Have you considered using Kotlin instead? :)
