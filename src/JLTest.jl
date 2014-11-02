module JLTest

_TESTCTX = :(testContext)

#Used to store test case state as testcase is executed
type TestContext
  name             #test case name
  curTest          #current test
  numRun           #num tests run
  numPassed        #num tests passed
  numFailed        #num assertions failed
  numErrors        #num assertions with errors
  numSkipped       #num tests skipped
  setUpCase        #before test case
  tearDownCase     #after test case
  setUp            #before test
  tearDown         #after test
  preAssert        #before assertion
  postAssert       #after assertion
  noprint          #disable outpt
  userData         #for user customization
  TestContext(desc) = new (desc,"",0,0,0,0,0,()->nothing, ()->nothing, ()->nothing, ()->nothing,(args...)->nothing, (args...)->nothing, false, nothing)
end

function printMsg(tc, args...;nl='\n')
  if tc.noprint;
  else
    print(args...,nl)
  end
end


function printTestReport(tc::JLTest.TestContext)
  local rep = "Run: $(tc.numRun) | Passed: $(tc.numPassed) | Failed: $(tc.numFailed) | Errors: $(tc.numErrors) | Skipped: $(tc.numSkipped)"
  local topLeft = repeat("=",int((length(rep) - length(tc.name) - 2)/2))
  local topRight = repeat("=", length(rep) - length(topLeft) - length(tc.name) - 2)
  local borderBot = repeat("=",length(rep))
  printMsg(tc,topLeft," ",tc.name," ", topRight)
  printMsg(tc,rep)
  printMsg(tc,borderBot)
end

function setUp(tc::JLTest.TestContext)
  try
    tc.numRun += 1
    tc.setUp()
  catch ex
    printMsg(tc,"Exception in setUp for ", tc.desc, " : ", ex)
  end
end

function doTest(tc::JLTest.TestContext, assertion::String, test::Function, args...)
  if !(test(args...))
    tc.numFailed += 1
    printMsg(tc,assertion,"(";nl="")
    for arg in args[1:end-1]
      printMsg(tc,arg,", ";nl="")
    end
    printMsg(tc,args[end], ") failed in ",tc.curTest)
    return false
  end
  return true
end

function handleException(tc::JLTest.TestContext, assertion, ex, bt)
  tc.numErrors += 1
  printMsg(tc,"Exception:", ex, " during ", assertion)
  Base.show_backtrace(STDOUT, bt)
end

function tearDown(tc::JLTest.TestContext)
  try
    tc.tearDown()
  catch ex
    printMsg(tc,"Exception in tearDown for ", tc.desc, " : ", ex)
  end
end

export @quiet
macro quiet()
  quote
    $(esc(_TESTCTX)).noprint = true
  end
end

export @unquiet
macro unquiet()
  quote
    $(esc(_TESTCTX)).noprint = false
  end
end

macro assertion1(assertion,arg1,test)
  quote
    local tc = $(esc(_TESTCTX))
    local a = $(esc(arg1))
    local success = false
    tc.preAssert(tc, $assertion,a)
    try
      success = doTest(tc, $assertion, $(esc(test)),a)
    catch ex
      bt=catch_backtrace()
      handleException(tc, $assertion, ex,bt)
    end
    if success
      tc.postAssert(tc, $assertion,a)
    end
  end
end

macro assertion2(assertion,arg1,arg2,test)
  quote
    local tc = $(esc(_TESTCTX))
    local a = $(esc(arg1))
    local b = $(esc(arg2))
    local success = false
    tc.preAssert(tc, $assertion, a, b)
    try
      success = doTest(tc, $assertion, $(esc(test)),a,b)
    catch ex
      bt=catch_backtrace()
      handleException(tc, $assertion, ex,bt)
    end
    if success
      tc.postAssert(tc, $assertion, a, b)
    end
  end
end

export @casename
macro casename(str)
  quote
    $(esc(_TESTCTX)).name = $str
  end
end


export @testname
macro testname(str)
  quote
    $(esc(_TESTCTX)).curTest = $str
  end
end

export @setUp
#set a function to be called before each test starts
macro setUp(func)
  quote
    $(esc(_TESTCTX)).setUp =  $(esc(func))
    nothing
  end
end

export @tearDown
#set a function to be called after each test finishes
macro tearDown(func)
  quote
    $(esc(_TESTCTX)).tearDown =  $(esc(func))
    nothing
  end
end

export @setUpCase
#set a function to be called before testcase starts
macro setUpCase(func)
  quote
    $(esc(_TESTCTX)).setUpCase =  $(esc(func))
    nothing
  end
end

export @tearDownCase
#set a function to be called after testcase finishes
macro tearDownCase(func)
  quote
    $(esc(_TESTCTX)).tearDownCase =  $(esc(func))
    nothing
  end
end

export @setPreAssert
#set a callback function to be called before each assert
#function should have signiture f(testCtx, assertion, args...)
#where testCtx is the testcase's TestContext, assertion is a string with name of assertion
#(e.g., "assertEqual") and args are values that will be passed to the assertion
#One possible use is in conjunction with userData to capture fine grained stats
macro setPreAssert(func)
  quote
    $(esc(_TESTCTX)).preAssert =  $(esc(func))
    nothing
  end
end

export @setPostAssert
#set a callback function to be called after testcase finishes.
#See setPreAssert for details
macro setPostAssert(func)
  quote
    $(esc(_TESTCTX)).postAssert =  $(esc(func))
    nothing
  end
end

export @setUserData
#store some data in the test context. Possibly for collecting custom test stats.
macro setUserData(data)
  quote
    $(esc(_TESTCTX)).userData =  $(esc(data))
    nothing
  end
end

export @getUserData
#get user data
macro getUserData()
  quote
    $(esc(_TESTCTX)).userData
  end
end

export @assertEqual
macro assertEqual(val1,val2)
  test = :((a,b)->(a == b))
  :( @assertion2("assertEqual", $(esc(val1)), $(esc(val2)), $(esc(test))) )
end

export @assertNotEqual
macro assertNotEqual(val1,val2)
  test = :((a,b)->(a != b))
  :(@assertion2("assertNotEqual",$(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertLess
#val1 < val2
macro assertLess(val1,val2)
  test = :((a,b)->(a < b))
  :(@assertion2("assertEqual",$(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertLessEqual
#val1 <= val2
macro assertLessEqual(val1,val2)
  test = :((a,b)->(a <= b))
  :(@assertion2("assertLessEqual",$(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertGreater
#val1 > val2
macro assertGreater(val1,val2)
  test = :((a,b)->(a > b))
  :(@assertion2("assertGreater",$(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertGreaterEqual
#val1 >= val2
macro assertGreaterEqual(val1,val2)
  test = :((a,b)->(a >= b))
  :(@assertion2("assertGreater",$(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertIs
#an obj1 is the same as obj2
macro assertIs(obj1,obj2)
  test = :((a,b)->(a === b))
  :(@assertion2("assertIs",$(esc(obj1)),$(esc(obj2)),$(esc(test))))
end

export @assertIsNot
#an obj1 is not the same as obj2
macro assertIsNot(obj1,obj2)
  test = :((a,b)->(a !== b))
  :(@assertion2("assertIsNot",$(esc(obj1)),$(esc(obj2)),$(esc(test))))
end

export @assertIn
#an obj not in collection
macro assertIn(obj,collection)
  test = :((a,b)->(a in b))
  :(@assertion2("assertIn",$(esc(obj)),$(esc(collection)),$(esc(test))))
end

export @assertNotIn
#an obj not in a collection
macro assertNotIn(obj,collection)
  test = :((a,b)->!(a in b))
  :(@assertion2("assertNotIn",$(esc(obj)),$(esc(collection)),$(esc(test))))
end

export @assertItemsEqual
#two collections equal ignoring order difference
macro assertItemsEqual(col1,col2)
  test = :((a,b)->(sort(a) == sort(b)))
  :(@assertion2("assertItemsEqual",$(esc(col1)),$(esc(col2)),$(esc(test))))
end

export @assertIsA
#an obj is a type
macro assertIsA(obj,typ)
  test = :((a,b)->isa(a,b))
  :(@assertion2("assertIsA",$(esc(obj)),$(esc(typ)),$(esc(test))))
end

export @assertIsNotA
#an obj is not a type
macro assertIsNotA(obj,typ)
  test = :((a,b)->!isa(a,b))
  :(@assertion2("assertIsNotA", $(esc(obj)),$(esc(typ)), $(esc(test))))
end

export @assertMatches
#a regex matches a string
macro assertMatches(regex,str)
  test = :((a,b)->ismatch(a,b))
  :(@assertion2("assertMatches", $(esc(regex)),$(esc(str)),$(esc(test))))
end

export @assertNotMatches
macro assertNotMatches(regex,str)
  test = :((a,b)->!ismatch(a,b))
  :(@assertion2("assertNotMatches", $(esc(regex)),$(esc(str)),$(esc(test))))
end

export @assertSameType
#type of val1 is same as type of val2
macro assertSameType(val1,val2)
  test = :((a,b)->(typeof(a) == typeof(b)))
  :(@assertion2("assertSameType", $(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertTypeOf
#type of val1 is typ
macro assertTypeOf(val,typ)
  test = :((a,b)->(typeof(a) == b))
  :(@assertion2("assertTypeOf", $(esc(val)),$(esc(typ)),$(esc(test))))
end

export @assertStrictlyEqual
#val1 == val2 and type of val1 is same as type of val2
macro assertStrictlyEqual(val1,val2)
  test = :((a,b)->(a == b && typeof(a) == typeof(b)))
  :(@assertion2("assertStrictlyEqual", $(esc(val1)),$(esc(val2)),$(esc(test))))
end

export @assertTrue
macro assertTrue(expr)
  test = :((a)->(isa(a,Bool) && a))
  :(@assertion1("assertTrue", $(esc(expr)),$(esc(test))))
end

export @assertFalse
macro assertFalse(expr)
  test = :((a)->(isa(a,Bool) && !a))
  :(@assertion1("assertFalse", $(esc(expr)),$(esc(test))))
end

export @testFailed(msg)
#Fail and print msg
macro testFailed(msg)
  test = :((a)->false)
  :(@assertion1("Failed",$(esc(msg)),$(esc(test))))
end

export @expectFailures
#Use to assert that n failures are expected at the point where macro appears
#and deduct from failure count
macro expectFailures(n)
  quote
    if $(esc(_TESTCTX)).numFailed != $(esc(n))
      printMsg($(esc(_TESTCTX)), "Error: ", $(esc(n))," expected failures but ", $(esc(_TESTCTX)).numFailed, " actual")
    else
      $(esc(_TESTCTX)).numFailed -= $(esc(n))
    end
  end
end

export @expectErrors
#Use to assert that n errors are expected at the point where macro appears
#and deduct from error count
macro expectErrors(n)
  quote
    if $(esc(_TESTCTX)).numFailed != $(esc(n))
      printMsg($(esc(_TESTCTX)), "Error: ", $(esc(n))," expected errors but ", $(esc(_TESTCTX)).numErrors, " actual")
    else
      $(esc(_TESTCTX)).numErrors -= $(esc(n))
    end
  end
end

STARTFAIL = :startFail
STARTERR = :startErr

export @suppressAll
#usage @suppressAll blk - suppress all failures, errors and msgs in blk
#usage @suppressAll nFailure blk - expect nFailures and suppress all errors and msgs in blk
#usage @suppressAll nFailure nErrors blk - expect nFailures and nErrors and suppress all msgs in blk
macro suppressAll(args...)
  l = length(args)
  if  l == 1
    nFailures = nErrors = -1
    block = args[1]
  elseif l == 2
    (nFailures,block) = args
    nErrors = -1
  elseif l == 3
    (nFailures,nErrors, block)  = args
  else
    error("wrong number arguements to suppressAll: $l")
  end
  quote
    local tc = $(esc(_TESTCTX))
    $(esc(STARTFAIL)) = tc.numFailed
    $(esc(STARTERR)) = tc.numErrors
    @quiet()
    $(esc(block))
    @unquiet()
    @expectFailures($nFailures >= 0 ? $nFailures : (tc.numFailed - $(esc(STARTFAIL))))
    @expectErrors($nErrors >= 0 ? $nErrors : (tc.numErrors - $(esc(STARTFAIL))))
  end

end

export @assertThrows
macro assertThrows(args...)
  if length(args) == 1
    exceps = []
    f = args[1]
  else
    exceps = args[1:end-1]
    f = args[end]
  end
  quote
    sexceps = $exceps
    try
      $(esc(f))
      $(esc(_TESTCTX)).numFailed += 1
      printMsg($(esc(_TESTCTX)),"assertThrows: Expected exception", length($exceps) > 0 ? "in $sexceps" : "")
    catch ex
      tex = typeof(ex).name.name
      if length($exceps) > 0 && !( tex in $exceps)
        $(esc(_TESTCTX)).numFailed += 1
        printMsg($(esc(_TESTCTX)), "assertThrows: Expected exceptions in $sexceps got $tex")
      end
    end
  end
end


export @testreport
macro testreport()
  quote
    printTestReport($(esc(_TESTCTX)))
  end
end

export @testcase
#Create test case around a block
macro testcase(args...)
  if length(args) == 1
    enabled = true
    block = args[1]
  else
    enabled = args[1]
    block = args[2]
  end
  if enabled
    quote
      let $(esc(_TESTCTX)) = JLTest.TestContext("No Name Test Case")
        local tc = $(esc(_TESTCTX))
        tc.setUpCase()
        $(esc(block))
        tc.tearDownCase()
        if tc.numErrors == 0 && tc.numFailed == 0
          printMsg(tc, tc.name, " Ok")
          if tc.numSkipped > 0
            printMsg(tc, tc.numSkipped, " Tests Skipped")
          end
        else
          printMsg(tc, tc.name, " FAILED! ", tc.numFailed, " failures ", tc.numErrors, " errors")
        end
      end
    end
  end
end

export @test
macro test(block)
  quote
    let tc = $(esc(_TESTCTX))
      numRun = tc.numRun += 1
      tc.curTest = "Test $numRun"
      local before = tc.numFailed + tc.numErrors
      tc.setUp()
      try
        $(esc(block))
      catch ex
        bt=catch_backtrace()
        handleException(tc,tc.curTest,ex,bt)
      end
      tc.tearDown()
      local after = tc.numFailed + tc.numErrors
      if before == after
        tc.numPassed +=1
      else
        printMsg(tc, tc.curTest, " Failed!")
      end
      tc.curTest = ""
    end
  end
end

export @testskip
#Place in front of a test to unconditionally skip it
macro testskip(args...)
  local skip, blk
  if length(args) == 1
    skip = true
    blk = args[1]
  elseif length(args) == 2
    (skip, blk) = args
  else
    error("@testskip accepts at most two arguments")
  end

  if skip
    quote
      $(esc(_TESTCTX)).numSkipped+=1
    end
  else
      :(@test($(blk)))
  end
end

end #JLTest
