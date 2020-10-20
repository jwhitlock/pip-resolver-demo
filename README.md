# Demo of issue with 2020 resolver

This is a minimized version of https://github.com/mozilla/ichnaea/pull/1289.
It was first reported as https://github.com/pypa/pip/issues/8792

With pip 20.2.4 (released and in development), this works:

```
pip install -r requirements.txt
```

However, this fails:

```
pip install -r requirements.txt --use-feature=2020-resolver
```

The error is:
```
ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==. These do not:
    pytz from https://files.pythonhosted.org/packages/4f/a4/879454d49688e2fad93e59d7d4efda580b783c745fd2ec2a3adf87b0808d/pytz-2020.1-py2.py3-none-any.whl#sha256=a494d53b6d39c3c6e44c3bec237336e14305e4f29bbf800b599253057fbb79ed (from Django==3.1->-r requirements.txt (line 3))
```

``pytz`` and other dependencies are specified in ``constraints.txt`` with hashes.
The 2020 resolver in pip 20.2.4 does not process hashes in a constraints file.

One work around is to load a constraints file like a regular requirements file:

```
pip install -r default.txt -r constraints.txt --use-feature=2020-resolver
```

The difference is that every package in the constraints file will be installed,
instead of installed only if needed.

This was tested in a virtualenv, and in Docker. If you have Docker setup, you
can run the installs with:

```
docker-compose build                      # All variants, stops on failure
docker-compose build new_resolver         # Just pip install -r requirements.txt --use-feature=2020-resolver
docker-compose build dev_resolver         # Install in-development version of pip
docker-compose build new_resolver_fixup   # Try the -r constraints.txt work around
```

The requirements are split between two files:
* ``requirements.txt``: ``-c constraints.txt``, main dependencies of the project
* ``constraints.txt``: the dependencies of the dependencies

The new resolver does not look at hashes in the constraints file.
