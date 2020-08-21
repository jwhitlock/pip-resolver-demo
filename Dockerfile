FROM python:3.8-slim

ARG PIP_EXTRA=--use-feature=2020-resolver
ARG REQS=default.txt
ARG PIP_SOURCE=pip

RUN echo "python -m pip install --upgrade \"${PIP_SOURCE}\""
RUN python -m pip install --upgrade "${PIP_SOURCE}"

RUN python -m pip freeze

COPY default.txt docs.txt shared.txt constraints.txt ./

RUN echo "pip install -r ${REQS} ${PIP_EXTRA}"
RUN pip install -r ${REQS} ${PIP_EXTRA}
