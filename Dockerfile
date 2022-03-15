FROM rightmesh/ubuntu-openjdk:18.04

ENV HOME=/home/oreo-user
RUN addgroup --gid 1000 oreo-user && adduser --uid 1000 --ingroup oreo-user --home "$HOME" --disabled-password oreo-user

RUN apt update && apt upgrade -y
RUN apt install --fix-missing -y apt-utils bash tar wget python3.6 python3-pip python3-venv libhdf5-dev gcc libopenblas-dev
# NOTE: this is for h5py

# RUN python3 -m ensurepip
# somehow the predictor depends on it
RUN ln -s /usr/bin/python3 /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip
RUN /usr/bin/python3 -m pip install --no-cache --upgrade pip wheel
# ANT
ENV APACHE_ANT_VERSION=1.10.12
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory-prefix /opt/ant/
RUN tar -xvzf /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory /opt/ant/
RUN rm -f /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz
ENV ANT_HOME=/opt/ant/apache-ant-$APACHE_ANT_VERSION
ENV PATH="${PATH}:${ANT_HOME}/bin"

# setup the runscript

# minor cleanup
# RUN apt-get clean autoclean && apt-get autoremove --yes
# RUN rm -rf /var/lib/{apt,dpkg,cache,log}/

USER oreo-user
WORKDIR "$HOME"
COPY ./oreo.tar.gz "$HOME"

RUN tar -xzvf oreo.tar.gz
RUN rm -f oreo.tar.gz

# this model is needed for oreo to have something for its prediction
# it is part of the artifact build, which is nice, but this allows it to change
# more easily

ENV CANDIDATES_DIR="$HOME/oreo/results/candidates"
ENV OUTPUT_DIR="$HOME/oreo/results/predictions"
COPY setup_venv.sh /
RUN bash /setup_venv.sh

COPY ./run_oreo.sh "$HOME"
ENTRYPOINT [ "bash", "/home/oreo-user/run_oreo.sh" ]