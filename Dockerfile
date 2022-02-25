FROM openjdk:18-alpine3.15

ENV HOME=/home/oreo-user
RUN addgroup --gid 1000 oreo-user && adduser --uid 1000 --ingroup oreo-user --home "$HOME" --disabled-password oreo-user

RUN apk add --update --no-cache bash tar wget python3 hdf5-dev gcc openblas-dev
RUN python3 -m ensurepip
# somehow the predictor depends on it
RUN ln -s /usr/bin/python3 /usr/bin/python && ln -s /usr/bin/pip3 /usr/bin/pip
RUN /usr/bin/python3 -m pip install --upgrade pip wheel
# ANT
ENV APACHE_ANT_VERSION=1.10.12
RUN wget http://archive.apache.org/dist/ant/binaries/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory-prefix /opt/ant/
RUN tar -xvzf /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz --directory /opt/ant/
RUN rm -f /opt/ant/apache-ant-$APACHE_ANT_VERSION-bin.tar.gz
ENV ANT_HOME=/opt/ant/apache-ant-$APACHE_ANT_VERSION
ENV PATH="${PATH}:${ANT_HOME}/bin"

# setup the runscript
COPY ./run_oreo.sh "$HOME"
RUN chmod +x "$HOME/run_oreo.sh"

USER oreo-user
WORKDIR "$HOME"
COPY ./oreo-FSE_Artifact.tar.gz "$HOME"

RUN tar -xzvf oreo-FSE_Artifact.tar.gz
RUN rm -f oreo-FSE_Artifact.tar.gz

# this model is needed for oreo to have something for its prediction
# it is part of the artifact build, which is nice, but this allows it to change
# more easily
ENV TRAINED_MODEL=oreo_model_fse.h5
COPY "$TRAINED_MODEL" "$HOME/"

ENTRYPOINT [ "/home/oreo-user/run_oreo.sh" ]