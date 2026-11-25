# Examples of the user's voice

Five excerpts from the user's own posts (2015 to 2021). They show rhythm and moves, not topics: don't copy their subjects or phrases. Minimal edits that the user approved are noted.

<example label="Opening with a stance, then speaking to the reader" source="2017, Lombok">
Java is a verbose language. No one disputes it. Despite the clunky nature of the language syntax, it still is the language of choice in most enterprises. If you work in the services industry or are a technology consultant, chances are that you have to work with Java on a regular basis.
</example>

<example label="Opinion, said plainly, landing on a contrast" source="2015, troubled startups">
Everyone wants to be the "next big thing". Everyone thinks they are the next Microsoft, Google, Facebook or Flipkart. Once in a while they are right. Usually they are wrong. Wanting to be great isn't a problem. Walking around thinking you are is.
</example>

<example label="Technical explanation with a worked example and exact numbers" source="2016, unit testing" edits="die for dice, Its for It's, emoticon dropped">
Typically a die produces values between 1 and 6.

Its corresponding test has to prove that rolling a die always results in a value between 1-6.

This test proves that the value is inside the range but does not prove that it will always be in that range. Since the implementation contains a PRNG, the end result cannot be predicted.

Most readers wouldn't have noticed the defect in the implementation.

The implementation can produce values 0-6. The fact that your test passed proves that it is a flaky unit test. The test has a 1/7 chance of failing. The fact that it didn't fail when you ran it is not surprising.
</example>

<example label="Team practice and the reason for it" source="2021, data storage" edits="first sentence shortened by deletion only">
When you have large volumes of data, we have found it useful to separate the data from upstream providers (if any) from the insights we produce. This allows us to segregate access (different parts have different PII classifications) and apply different retention policies.
</example>

<example label="Closing on a decision, with a dry question" source="2017, Lombok" edits="emoticon dropped">
If your team can answer yes to all of the above, you should use Lombok. I must admit, most large teams can't answer yes to all of the questions. Have you considered using Kotlin instead?
</example>

Note: these predate the user's newer choices. They have no serial comma and some one-sentence paragraphs. Follow `voice.md` and the linter on those points, not the examples.
