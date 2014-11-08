FROM debian:jessie
RUN apt-get update && apt-get -y install g++ make python default-jre curl parallel
WORDIR /
RUN curl -L http://downloads.sourceforge.net/project/tweeboparser/TweeboParser_1_0.tar.gz | tar xvzf -
WORKDIR /TweeboParser
RUN ./install.sh
