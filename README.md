# Demo of issue with 2020 resolver

This is a minimized version of https://github.com/mozilla/ichnaea/pull/1289.
It is reported as https://github.com/pypa/pip/issues/8792

With pip 20.2.4 (released and in development), this works:

```
pip install -r default.txt
```

However, this fails:

```
pip install -r default.txt --use-feature=2020-resolver
```

The error is:
```
ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==. These do not:
    chardet<4,>=3.0.2 from https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl#sha256=fc323ffcaeaed0e0a02bf4d117757b98aed530d9ed4531e3e15460124c106691 (from requests[security]==2.24.0->-r default.txt (line 5))
```

``chardet`` and other dependencies are specified in ``constraints.txt`` with hashes.
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
docker-compose build new_resolver         # Just pip install -r default.txt --use-feature=2020-resolver
docker-compose build dev_resolver         # Install in-development version of pip
docker-compose build new_resolver_fixup   # Try the -r constraints.txt work around
```

Our requirements are split between two files:
* ``default.txt``: ``-c constraints.txt``, main dependencies of the project
* ``constraints.txt``: the dependencies of the dependencies

The new resolver does not look at hashes in the constraints file.

An alternate scenario is shown with:

* ``django.txt``: Specifies a minimum version of Django
* ``django-version.txt``: Specifies the exact versions with hashes
