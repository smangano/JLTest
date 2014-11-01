module JLTestTest

using JLTest

@testcase false begin
  @casename "JLTest Private Impl Tests"

  @test begin
    tc = JLTest.TestContext("Dummy")
    expected = true
    result = JLTest.doTest(tc, "assertEquals", (a,b)->(a==b), 1, 1)
    assert(expected == result)
  end

  @test begin
    tc = JLTest.TestContext("Dummy")
    expected = false
    result = JLTest.doTest(tc, "assertEquals", (a,b)->(a==b), 1, 2)
    assert(expected == result)
  end

end

@testcase begin

  @casename "JLTest Tests"

  x = 0

  @setUp () -> (x+=1)
  @tearDown () -> (x=0)

  @test begin
    @testname "assertEqual Tests"
    @assertEqual(x,1)
    @assertEqual(x,1)
  end

  @test begin
    @testname "assertNotEqual Tests"
    @assertNotEqual(x,0)
  end

  @test begin
    @testname "assertLess Tests"
    @assertLess(-1,1)
  end

  @test begin
    @testname "assertLess Tests"
    @assertLessEqual(-1,1)
  end

  @test begin
    @testname "assertLessEqual Tests"
    @assertLessEqual(1,1)
  end

  @test begin
    @testname "assertGreater Tests"
    @assertGreater(1,-1)
  end

  @test begin
    @testname "assertGreaterEqual Tests"
    @assertGreaterEqual(-1,-1)
  end

  myString1 = "a string"
  myString1a = myString1
  myString2 = "a string"
  myArray1 = [1,2,3]
  myArray1a = myArray1
  myArray2 = copy(myArray1)

  @test begin
    @testname "assertIs Tests"

    @assertIs(myString1, myString1a)
    @assertIs(myArray1, myArray1a)
  end

  @test begin
    @testname "assertIsNot Tests"
    @assertIsNot(myString1, myString2)
    @assertIsNot(myArray1, myArray2)
  end

  @test begin
    @assertIn(2, [1,2,3])
  end

  @test begin
    @assertNotIn(0, [1,2,3])
  end

  @test begin
     @assertItemsEqual([3,2,1], [1,2,3])
  end

  @test begin
    @assertIsA([3,2,1], Array)
  end

  @test begin
    @assertIsA([3,2,1], Array{Int64,1})
  end

   @test begin
     @assertIsNotA([3,2,1], Array{Int32,1})
  end

  @test begin
    @assertMatches(r"a[0-9]+a", "a1234a")
  end

  @test begin
    @assertNotMatches(r"a[0-3]+a", "a1234a")
  end

  @test begin
    a = 2
    b = 1
    @assertTrue(a==2*b)
  end

  @testskip begin
    @testname "uncond skip"
    @testFailed("Should have been skipped")
  end

  @testskip true begin
    @testname "skip with cond"
    @testFailed("Should have been skipped")
  end

  @test begin
    @testname "expected errors"
    @suppressAll 1 0 begin
      @testFailed("I expect this to fail")
    end
  end

  @test begin
    @testname "assertThrows specific exception"
    d = Dict()
    @assertThrows KeyError d["bogus"]
  end

  @test begin
    @testname "assertThrows one of specified exceptions"
    d = Dict()
    @assertThrows KeyError ErrorException error("ouch")
  end

   @test begin
    @testname "assertThrows any exception"
    d = Dict()
    @assertThrows error("boom")
  end

  @test begin
    @testname "assertThrows reports exception was not thrown"
    d = Dict()
    @suppressAll 1 0 begin
      @assertThrows ()->"I dont throw"()
    end
  end

  @test begin
    @testname "assertThrows reports exception was not thrown from a list of possible"
    d = Dict()
    @suppressAll 1 0 begin
      @assertThrows KeyError ErrorException ()->"I dont throw"()
    end
  end

  @test begin
    @testname "assertThrows reports exception was thrown but not in expected list"
    d = Dict()
    @suppressAll 1 0 begin
      @assertThrows KeyError error("I throw ErrorException")
    end
  end

  @test begin
    @testname "type related tests"
    @assertTypeOf(1, Int64)
    @assertSameType(1, 1000)
    @assertStrictlyEqual(4, 2 * 2)
    @suppressAll 1 0 begin
      @assertStrictlyEqual(4, 2.0 * 2)
    end
  end

  @testreport

end

type AssertEqualCheck
  numAssertEqual
  numAssertEqualSuccess
  numAssertEqualDiffTypes
end

@testcase begin @casename "Customization"

  @setUserData AssertEqualCheck(0,0,0)
  @setPreAssert (tc, assertion, args...)-> assertion == "assertEqual" && (tc.userData.numAssertEqual+=1;true)
  @setPostAssert function postStats(tc, assertion, args...)
    if assertion == "assertEqual"
      tc.userData.numAssertEqualSuccess  += 1
      if typeof(args[1]) != typeof(args[2])
        tc.userData.numAssertEqualDiffTypes+=1
      end
    end
  end

  @test begin
    @testname "test pre/post asserts"
    @assertEqual(1.0, 1)
    @assertEqual(1, 1)
    @quiet
    @assertEqual(1, 2) #will fail and not call post assert
    @expectFailures(1)
    @unquiet
    @assertNotEqual(1,0)
    aec = @getUserData()

    #Don't use assertEqual here unless you reset pre/post hooks!
    @assertTrue(aec.numAssertEqual == 3)
    @assertTrue(aec.numAssertEqualSuccess == 2)
    @assertTrue(aec.numAssertEqualDiffTypes == 1)
  end
end

end #module
