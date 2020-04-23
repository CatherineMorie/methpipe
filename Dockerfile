FROM python:3.7 AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
gsl-bin \
libgsl-dev \
zlib1g-dev \
&& mkdir -p /methpipe/ \
&& curl -s http://smithlabresearch.org/downloads/methpipe-3.4.3.tar.bz2 \
| tar -xj -C /methpipe --strip-components=1 \
&& export CPATH=/path_to_my_gsl/include \
&& export LIBRARY_PATH=/path_to_my_gsl/ \
&& export PATH=$PATH:$METHPIPE/bin

WORKDIR /methpipe

RUN make all && make install

FROM python:3.7-slim

RUN groupadd --gid 1000 user \
&& useradd --uid 1000 --gid user --shell /bin/bash --create-home user

COPY --from=build /methpipe/bin .

RUN apt-get update && apt-get install -y --no-install-recommends gsl-bin git emacs perl6 && rm -rf /var/lib/apt/lists/*

USER user

CMD [ "/bin/bash" ]
