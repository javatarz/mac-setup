"""Run the skill tests and print failures as short messages, not tracebacks.

Test authors put the full explanation (what broke, where, why, how to fix)
in the assertion message. Unexpected errors (real exceptions) still show a
traceback, since those are bugs in the tests themselves.
"""
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))


class MessageOnlyResult(unittest.TextTestResult):
    def addFailure(self, test, err):
        super().addFailure(test, err)
        # replace the formatted traceback with just the assertion message
        self.failures[-1] = (test, str(err[1]))

    def printErrorList(self, flavour, errors):
        for test, msg in errors:
            self.stream.writeln("=" * 70)
            self.stream.writeln(f"{flavour}: {test.id()}")
            self.stream.writeln(msg.rstrip())
            self.stream.writeln("")


def main():
    suite = unittest.defaultTestLoader.discover(HERE, pattern="test_*.py")
    runner = unittest.TextTestRunner(resultclass=MessageOnlyResult, verbosity=0)
    return 0 if runner.run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main())
