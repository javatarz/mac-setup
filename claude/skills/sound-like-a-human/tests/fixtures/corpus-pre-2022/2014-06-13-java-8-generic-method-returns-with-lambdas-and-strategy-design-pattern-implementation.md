# Java 8: Generic Method Returns with Lambdas and Strategy Design Pattern implementation

With the introduction of Functional Programming in Java 8 new possibilities have opened up. One use case I recently encountered was that of processing JSONs to return data inside them. Let us, for the sake of argument, say the data in an element could be one of the following:

- An `Integer` e.g. `1`

- A `String` e.g. `The quick brown fox jumps over the lazy dog`

- A `JsonObject` representing a Java Object e.g. `{"payload":[{"lastName\":\"AB","firstName":"Karun","email":"test[at]email.com"}`

- A `JsonArray` containing `Integer`s e.g. `[1, 2, 3]`

- A `JsonArray` containing `String`s e.g. `["String 1", "String 2"]`

- A `JsonArray` containing `JsonObject`s representing Java Objects e.g. `[{"lastName":"AB","firstName":"Karun","email":"test[at]email.com"},{"lastName":"FooBar","firstName":"Kung","email":"kung[at]foobar.com"}]`

If you want such a wide variety of data parsed and handled (relatively) safely (i.e. with compile time type safety where possible), here is what you do.

#### Functional interface for Lambda definition

First you need a `FunctionalInterface` that defines your operation. Here is a sample.

This methods defines the task to be performed for parsing data which is a `JsonElement` (I’m using google-gson for my JSON parsing needs).

#### Super Type Token management

If your key eyes have picked it up, I have an undefined class here called `TypeReference` which is inspired from Neal Gafter’s old blog post but has a extra method to check the super type for generics. I recommend reading through his blog post before proceeding.

Here is my version. The only changes I’ve made are around the `superType` variable being added. If you apply wish to use `List<String>` as your return type reference, the `type` would be `List` and the `superType` would be `String`. If you use `String` as your return type reference, the `type` will be `String` and the `superType` will be `null`.

Now we need a simple `User` class which maps to the sample data I provided earlier.

#### Defining your data processor

Here’s why you just bumped your project up to use Java 8 as a minimum. You can pass functional parameters to methods ensuring the caller decides how their data is to be processed.

This method parses your data as a JSON and takes the payload out (you’ll see the complete structure of data in the main function below). The caller also provides you the processor to process his data along with the return type that is expected.

#### Sample Lambdas

Time to define some lambdas based on the sample data we talked about earlier

If your return type is a single item (not a `List`), you should be using `itemProcessor`. `listProcessor` returns a `List` of items defined as the `superType` of the `typeRef`.

#### Using your lambdas

Let us bring it all together and show you how to call your method now

As you can see, `parseData` returns different data types (that are type safe as long as you provided the correct processor for the correct type of data) that are compile time safe.

#### Why use the superType in TypeReference?

At this point you could argue that the `superType` could be skipped because the `listProcessor` only uses `typeRef.getSuperType()` and instead could easily use `typeRef.getTypeClass()` and get away with it. You’d be correct. But it would mean everyone would have to live with my choice of the collection (in this case, an `ArrayList`). Instead you can use `typeRef.newInstance()` to generate new instances of any class with a default constructor (like `ArrayList`, `Vector`, `HashMap` etc.) and operate on it.

This way, you can have a `listProcessor` that can let the caller decide which `List` implementation they want to use. All the more power to Strategy Pattern! Your lambdas now represent individual strategies.

##### Sample Output
