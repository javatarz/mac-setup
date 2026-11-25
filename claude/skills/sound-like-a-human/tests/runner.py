"""Run the skill tests and print failures as short messages, not tracebacks.

Test authors put the full explanation (what broke, where, why, how to fix it)
in the assertion message. Unexpected exceptions are reduced to the exception
and the last frame, so a syntax error in lint.py is one readable block.
"""
import os
import sys
import traceback
import unittest

sys.dont_write_bytecode = True  # the repo has no .gitignore for __pycache__

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPTS = os.path.normpath(os.path.join(HERE, "..", "scripts"))


def rel(path):
    """Path relative to the caller's cwd (run.sh cds, so it passes the original)."""
    return os.path.relpath(path, os.environ.get("TESTS_CALLER_CWD", os.getcwd()))


def describe_exception(exc, tb=None):
    """One short block: where, what, and how to fix."""
    if isinstance(exc, SyntaxError):
        where = f"{rel(exc.filename)}:{exc.lineno}" if exc.filename else "unknown location"
        detail = f"SyntaxError: {exc.msg}" + (f"\n    {exc.text.strip()}" if exc.text else "")
    else:
        frames = traceback.extract_tb(tb or exc.__traceback__)
        # last frame is where it blew up; fall back gracefully when there is none
        last = frames[-1] if frames else None
        where = f"{rel(last.filename)}:{last.lineno}" if last else "unknown location"
        detail = f"{type(exc).__name__}: {exc}"
    return (f"  where: {where}\n  what:  {detail}\n"
            "  fix:   fix the error at that location, then re-run the tests.")


class MessageOnlyResult(unittest.TextTestResult):
    def addFailure(self, test, err):
        super().addFailure(test, err)
        # replace the formatted traceback with just the assertion message
        self.failures[-1] = (test, str(err[1]))

    def addError(self, test, err):
        super().addError(test, err)
        self.errors[-1] = (test, "UNEXPECTED ERROR (not a test assertion)\n" + describe_exception(err[1], err[2]))

    def printErrorList(self, flavour, errors):
        for test, msg in errors:
            self.stream.writeln("=" * 70)
            self.stream.writeln(f"{flavour}: {test.id()}")
            self.stream.writeln(msg.rstrip())
            self.stream.writeln("")


def main():
    # Import the linter first: a syntax or import error in it would otherwise
    # surface once per test module as a long traceback.
    sys.path.insert(0, SCRIPTS)
    try:
        import lint  # noqa: F401
    except Exception as exc:  # SyntaxError is an Exception
        print("ERROR: scripts/lint.py cannot be imported, so no tests ran.")
        print(describe_exception(exc))
        return 1
    suite = unittest.defaultTestLoader.discover(HERE, pattern="test_*.py")
    runner = unittest.TextTestRunner(resultclass=MessageOnlyResult, verbosity=0)
    return 0 if runner.run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main())
