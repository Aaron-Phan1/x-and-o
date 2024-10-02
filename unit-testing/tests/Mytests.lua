print("--- Unit tests start here ---") -- a header, so we can find the test results on the console
lunatest.suite("tests.hard-mode-tests") -- where to find the tests
lunatest.suite("tests.easy-mode-tests") -- where to find the tests
lunatest.suite("tests.play-move-tests") -- where to find the tests

lunatest.run() -- run the tests

