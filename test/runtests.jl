using JLTest

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
    @testFailed("I expect this to fail")
    @expectFailures(1)
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
    @assertThrows ()->"I dont throw"()
    @expectFailures(1)
  end

  @test begin
    @testname "assertThrows reports exception was not thrown from a list of possible"
    d = Dict()
    @assertThrows KeyError ErrorException ()->"I dont throw"()
    @expectFailures(1)
  end

   @test begin
    @testname "assertThrows reports exception was thrown but not in expected list"
    d = Dict()
    @assertThrows KeyError error("I throw ErrorException")
    @expectFailures(1)
  end

  @testreport

#   #should fail
#   @assertEqual(x,0)

#   #should get DomainError
#   @assertEqual(sqrt(-1),0)

end


# macroexpand(:(@testCase begin

#   @testname "JLTest Tests"

#   x = 0

#   @setUp () -> (x+=1)
#   @tearDown () -> (x=0)

#   @assertEqual(x,1)

#   @assertEqual(x,1)

#   @assertEqual(x,0)

# end))

# macroexpand(:(@testCase begin
#   myString1 = "a string"
#   myString1a = myString1
#   myString2 = copy(myString1)

#   @assertIsNot(myString1, myString2)
# end))

# @testCase begin
#   myString1 = "a string"
#   myString1a = myString1
#   myString2 = deepcopy(myString1)

#   @assertIsNot(myString1, myString2)
# end

# macroexpand(:(@testCase begin

#   @testCaseName "JLTest Tests"

#   x = 0

#   @setUp () -> (x+=1)
#   @tearDown () -> (x=0)

#   @test begin
#     @testname "assertEqual Tests"
#     @assertEqual(1,1)
#   end
# end
# ))

