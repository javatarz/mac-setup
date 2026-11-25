# Commonly made mistakes in Unit Testing

### What is Unit Testing?

Unit testing is all about focusing on one element of the software at a time. This unit is called the often called the ‘System Under Test’ (refer Mocks Aren’t Stubbs). In order to test only one unit at a time, all other units need to not be test at the same time. As obvious as that sounds, it’s easy to miss.

Classes do not exist independent of one another. They usually have dependencies. Such dependencies are called the ‘Collaborators’. There are multiple ways to manage collaborators that have been talked about by Martin in his article.

#### Pre-requisites to the post before going forward

Before we go on, please ensure you’ve read through Mocks Aren’t Stubbs by Martin Fowler. This post assumes that you’ve gone through the article before continuing on to commonly made mistakes in Unit Testing

### Mocks vs Actual Implementations

Consider a board game where the Board class runs the game with the help of it’s collaborators `Player` and `Dice`.

If we consider the `Board` to be the System Under Test, the most tempting trap to fall into is start testing the Board directly.

This is not the greatest example but it does attempt to show you the coupling between the different components. Player1’s current position isn’t predictable since it’s coupling with dice. The dependency also means that if the dice has defects, the board can’t be tested appropriately.

By swapping out player and dice instances with mocks, we have the ability to only test the board independent of potential issues with the dependencies.

The above test can be refactored to look like

The test now allows you to check if `player1` was moved 3 places since the response provided by the dice is in your control. Mocks also allow you to test that `player2` was not called.

This becomes even more important in an example where the response from the mock affects the system under test. Controlling the mock allows you to control predict the end state of the system under test with the assumption that your mock setup is correct. These assumptions can be validated with the spec for the individual mocks. The unit test for dice mock can confirm that the dice only returns values between 1 and 6 (inclusive).

### Testing inside the boundaries

Every functionality should be tested within it’s boundaries. Let’s take the `Dice` class as an example and talk about what this means.

Typically a dice produces values between 1 and 6.

It’s corresponding test has to prove that rolling a dice always results in a value between 1-6.

This test proves that the value is inside the range but does not prove that it will always be in that range. Since the implementation contains a PRNG, the end result cannot be predicted.

Most readers wouldn’t have noticed the defect in the implementation.

The implementation can produce values 0-6. The fact that your test passed proves that it is a flaky unit test. The test has a 1/7 chance of failing. The fact that it didn’t fail when you ran it is not surprising :)

### DI, your new best friend

The anti-pattern to take away from the previous example is that the Dice class relies on a library and that the library is contained in the class. The fact that it can’t be injected means that you can’t control it.

Dependency Injection is your friend!

Now, your test can work with a mocked `Random` instance for more accurate results.

We’re currently making 2 assumptions on the collaborator.

- `random.nextInt` is always called with parameter `5`

- `random.nextInt(5)` always returns values between 0 and 5

The first assumption is in part validated by the mocking library. If `Dice` called by any other parameter, the results wouldn’t be what we want. But if you want to be extra sure, you could always make the test fail using an argument captor

The second assumption should not be validated by you. If you look at the documentation for `random.nextInt()` you will notice

It is the responsibility of the library (`java.util.Random` in this case) to test itself.

How do I know `Random` will not misbehave? I don’t. The `Dice` component could be integration tested. It is an absolute necessity if you deem the component to be an untrusted collaborator. If this was a database connection or a REST call, you’d want that. For a Java util or a well tested open source library, you could be forgiven for not writing an integration test.

In this case, I won’t be writing one for sure! ☺
