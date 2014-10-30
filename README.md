# JLTest

[![Build Status](https://travis-ci.org/smangano/JLTest.jl.svg?branch=master)](https://travis-ci.org/smangano/JLTest.jl)

A unittest framework for Julia (inspired by Python's unittest)

## Usage
-------------------------------------------------------
    using JLTest

    @testcase begin
        @casename "Mytest Tests"

        #Some code
        x = 0

        #Function to be called before each test (optional)
        @setUp () -> (x+=1)

        #Function to be called after each test (optional)
        @tearDown () -> (x=0)

        @test begin
            @testname "A Simple Test" #Name of test (optional)
            @assertEqual(x,1)
        end

        #more tests or code...

    end # end of test case
-------------------------------------------------------

## Available Test Macros
NOTE: [...] below indicates optional args not array

###@testcase begin ... end

Setup a test case (collection of related tests)

###@test begin ... end

Setup a test

###@testskip [cond] begin ... end

Skip this test if cond is true or always skip if cond ommited

###@casename "test case name"

###@testname "test name"

###@setUp function

###@tearDown function

Set a function to be called after each test finishes

###@assertEqual(a,b)

a == b

###@assertNotEqual(a,b)

a != b

###@assertLess(a,b)

a < b

###@assertLessEqual(a,b)

a <= b

###@assertGreater(a,b)

a > b

###@assertGreaterEqual(a,b)

a >= b

###@assertIs(a,b)

a === b

###@assertIsNot(a,b)

a !== b

###@assertIn(a,collection)

a in collection

###@assertNotIn(a, collection)

! (a in collection)

###@assertItemsEqual(col1, col2)

sort(col1) == sort(col2)

###@assertIsA(obj, type)
###@assertIsNotA(obj, type)

###@assertMatches(regex, string)

###@assertNotMatches(regex, string)

###@assertTrue(bool)

###@assertFalse(bool)

###@testFailed(msg)

Fail test and display msg

###@expectFailures(n)

Declare that n assertion failures expected at this point in test and should be ignored

###@expectErrors

Declare that n errors are expected at this point in test and should be ignored
Errors are unexpected exceptions raised during a test

###@assertThrows block|expr|function

Declare that some code is expected to throw an exception

###@assertThrows [ex1,ex2,...] block|expr|function

Declare that some code is expected to throw an exception of type ex1 or ex2, ...

###@testreport

Output a summary of number of tests run, passed, failed, errored, skipped

