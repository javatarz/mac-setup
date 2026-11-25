# Project Euler #79: Passcode Derrivation (using Lambdas)

I’ve been solving Project Euler for years and I avoid posting solutions online as far as possible but this problem is old enough that it shouldn’t be a problem. Plus, the problem statement interests me enough to write a functional solution using the new Java 8 Lambdas that I’ve been experimenting over the past few months.

Before I begin, I’d like to acknowledge Alex Michael for providing the base solution with a pretty nice explanation of how to crack the problem. You should read through his post before you continue.

My solution provides a Java port of this solution using Lambdas. Here are the steps to the solution

## Solution Process

- Read file to a List of Strings viz. ‘passcodes’

- Process each ‘passcode’ in ‘passcodes’ using a ‘passcodeConsumer’ 1. separate digits of the passcode and add them to a ‘digitUniverse’ set which contains all digits that the solution has 2. separate digits of the passcode and ‘update connections’ 3. merge connections created for this passcode with past ones

- iterate through every key in the master connection relationship graph considering them as the parent before doing a BFS to find the possible solutions using recursion

## Solution Walkthrough

### Reading the passcodes

We’ve added keylog.txt into the project’s build path so we can read it. Thanks to the magic of Java 7’s NIO Files API, it’s a one line job to read files now.

This can optionally be replaced with the following lines for testing the solution. The explanation further will hinge on these values

### Processing passcodes

This processing requires someone to first iterate through the passcodes, find all digits in the passcode to maintain a unique set of digits required for the overall solution (called the ‘digit universe’) and calculate ‘connections’ between digits (order of appearance of digits in the solution)

Each of the lambdas and data structures used here are described below

#### Digit Separator

This function simply iterates through the characters of the string and converts them into integers. As you see, this function will be required multiple times later

#### Maintaining a Digit Universe

This is a straight forward function to update the data structure for the digit universe. The chosen data structure is a Java Set to ensure values are unique. Since the order of appearance isn’t important to us and the HashSet implementation’s performance is good enough for our requirement, we can use it.

#### Updating Connections

The connections data structure maintains relationships between digits defining the order which digits occur. For a number 541, the relationship would suggest digits 4 and 1 come after 5 and that the digit 1 comes after 4. When the number 541 is processed, the connections map will contain the following content (assuming it was empty earlier)

> 5 -> [1, 4]

> 4 -> [1]

> 1 -> []

The order of appearance inside the Set doesn’t matter. The result here contains 1 before 4 only because the Set implementation used was a HashSet which naturally sorts data (meaning numbers get arranged in ascending order).

It is important to note that the data structure ‘connections’ is temporary and only contains state for the current passcode being processed. This means that the solution cannot be parallelized as long as this state is being maintained. Then again, our solution can’t be parallelized because Java Maps can’t be streamed. Maybe I’ll update this solution to make it parallel eventually.

The ‘connections’ state is processed to update the master data set of connections by using a custom merge logic.

#### Connection merging

The connection merge is applied on an entry of the connection data structure. the key and contenderValues are variables that hold information about an entry in the connections map. If the passcode being processed was 541, each of rows mentioned above as being in the connection map (such as “5 -> [1, 4]”) will be an entry this consumer will consume.

The targetValues are a Set that contains any data that the masterConnections already has for the same key. If the targetValues Set is null then the digit in the key is being encountered for the first time and so the map will be updated with an empty HashSet. Irrespective of whether targetValues existed or not, the next step is to add all the contenderValues into the targetValues Set. The underlying masterConnections data structure is kept up to date because the maps are backed (the same object reference is used internally to ensure data is kept up to date).

Once the merge is complete the passcodeConsumer has to ensure that the consumer is cleared so it’s ready for the processing of the next passcode

### Finding longest solutions

This step iterates through every entry in the masterConnection map considering that its a master and finds the longest solution for each vertex in the graph. If the possibleSolution length is 0, there was no solution that used all digits in the digitUniverse.

The findPossibleSolution method recursively digs through the child nodes of the currentNode to find child nodes.

When a leaf node is found, the parent nodes are used to trace out the path traversed along the map which represents a candidate solution. The Set implementation used was a LinkedHashSet to ensure the order of the path traced to the child node is maintained. Validity of each candidate solution is tested to confirm if every one of the digits of the digitUniverse are included in the candidate. If so, the candidate is returned or an empty string is returned.

When the current node is not a leaf node, all child nodes are iterated through and the findPossibleMethod is recursively invoked to generate a solution. The solutions are then reduced to ensure a solution of the least length is returned. If two solutions have the same length, the one which was found first is returned (the choice is arbitrary at that point since the question asks for any valid solution of minimum length is found).

### Bringing it all together

All you now need is a main function to do your bidding

### Update

Alex’s original solution assumes that digits will not be repeated. This is an assumption that is validated by the input data set for the problem. But in real life, this does not hold true. If your input is 123 and 325 the only solution you can have is 12325 since the two inputs clearly show that the digit 2 appears before and after 3 (unless the digit 3 is also repeated; which though would be a valid solution, it wouldn’t be an optimal one since the problem requires the shortest answer). This solution cannot be fetched as long as data is stored in Sets because they wade out repetitions. The implementation can be migrated to use Lists instead. The other change required would be the master connections data structure should now possess the ability to track which node connections have been traversed in the recursion. To ensure there is no inappropriate data sharing in the recursion, each recursive call is isolated by performing deep copy on the parent list (and master connections data structures).

include_code lang:java project-euler-79-passcode-derrivation-using-lambdas/PasscodeGenerator.java

The path class simply defines a structure to track nodes and whether they have been traversed yet.

include_code lang:java project-euler-79-passcode-derrivation-using-lambdas/Path.java
