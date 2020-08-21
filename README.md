# Demo of issue with 2020 resolver

This is a minimized version of https://github.com/mozilla/ichnaea/pull/1289.

With pip 20.2.2, these both work:

```
pip install -r default.txt  # Used in our development environment
pip install -r docs.txt     # Used in readthedocs.org build
```

However, these fail:

```
pip install -r default.txt --use-feature=2020-resolver
pip install -r docs.txt --use-feature=2020-resolver
```

The first fails with:
```
ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==. These do not:
    chardet<4,>=3.0.2 from https://files.pythonhosted.org/packages/bc/a9/01ffebfb562e4274b6487b4bb1ddec7ca55ec7510b22e4c51f14098443b8/chardet-3.0.4-py2.py3-none-any.whl#sha256=fc323ffcaeaed0e0a02bf4d117757b98aed530d9ed4531e3e15460124c106691 (from requests[security]==2.24.0->-r shared.txt (line 9))
```

The second with:
```
ERROR: In --require-hashes mode, all requirements must have their versions pinned with ==. These do not:
    idna<3,>=2.5 from https://files.pythonhosted.org/packages/a2/38/928ddce2273eaa564f6f50de919327bf3a00f091b5baba8dfa9460f3a8a8/idna-2.10-py2.py3-none-any.whl#sha256=b97d804b1e9b523befed77c48dacec60e6dcb0b5391d57af6a65a312a90648c0 (from requests[security]==2.24.0->-r shared.txt (line 8))
```

Both ``chardet`` and ``idna`` are specified in ``constraints.txt``.

This was tested in a virtualenv, and in Docker. If you have Docker setup, you can run the four installs with:

```
docker-compose build  # All four variants, stops on failure
docker-compose new_resolver_default  # Just pip install -r default.txt --use-feature=2020-resolver
docker-compose new_resolver_docs     # Just pip install -r docs.txt --use-feature=2020-resolver
docker-compose dev_resolver_default  # Install in-development version of pip
docker-compose dev_resolver_docs     # Install in-development version of pip
```

Our requirements files include other files, as a way to only specify a requirement once for two different environments:
* ``default.txt``: ``-c constraints.txt``, ``-r docs.txt``, ``-r shared.txt``
* ``docs.txt``: ``-c constraints.txt``, ``-r shared.txt``
* ``shared.txt``: None
* ``contraints.txt``: None

The files with issues are included in two different paths (determined with ``pipdeptree``). For example, ``idna`` is included twice:

* ``Sphinx`` (``docs.txt``)
   - requires ``requests`` (``shared.txt``)
      - requires ``idna`` (``constraints.txt``)
* ``geoip2`` (``default.txt``)
   - requires ``aiohttp`` (``constraints.txt``)
      - requires ``yarl`` (``constraints.txt``)
         - requires ``idna`` (``constraints.txt``)
