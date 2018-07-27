FROM ubuntu:16.04
MAINTAINER Ryan Kennedy <hello@ryankennedy.io>
ENV gatewayscript=ibgateway-latest-standalone-linux-x64-v968.2d.sh

RUN apt-get update \
  && apt-get install -y wget \
  && apt-get install -y unzip \
  && apt-get install -y xvfb \
  && apt-get install -y libxtst6 \
  && apt-get install -y libxrender1 \
  && apt-get install -y libxi6 \
  && apt-get install -y socat \
  && apt-get install -y software-properties-common

# Setup IB TWS
RUN mkdir -p /opt/TWS
WORKDIR /opt/TWS
RUN wget -q http://cdn.quantconnect.com/interactive/$gatewayscript \
  && chmod a+x $gatewayscript

# Setup  IBController
RUN mkdir -p /opt/IBController/
WORKDIR /opt/IBController/
RUN wget -q https://github.com/ib-controller/ib-controller/releases/download/3.4.0/IBController-3.4.0.zip \
 && unzip ./IBController-3.4.0.zip \
 && chmod -R u+x *.sh && chmod -R u+x Scripts/*.sh \
 && mkdir Logs

# Install Java 8
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
  && add-apt-repository -y ppa:webupd8team/java \
  && apt-get update \
  && apt-get install -y oracle-java8-installer \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/oracle-jdk8-installer

# Install python and pip
RUN mkdir -p /opt/pythonSetup/
WORKDIR /opt/pythonSetup/
RUN  add-apt-repository ppa:deadsnakes/ppa \
  && apt-get update \
  && apt-get -y install python3.6 \
  && wget https://bootstrap.pypa.io/get-pip.py \
  && python3.6 get-pip.py

# Install ib api
RUN mkdir -p /opt/ibapi/
WORKDIR /opt/ibapi/
RUN wget http://interactivebrokers.github.io/downloads/twsapi_macunix.973.07.zip \
  && unzip twsapi_macunix.973.07.zip \
  && cd IBJts/source/pythonclient/ \
  && python3.6 setup.py install

# Install ib_insync
RUN pip3 install ib_insync

# Demo setup 
RUN  apt-get install vim
ADD demo.py demo.py

WORKDIR /

# Install TWS
RUN yes n | /opt/TWS/$gatewayscript

#CMD yes

# Launch a virtual screen
RUN Xvfb :1 -screen 0 1024x768x24 2>&1 >/dev/null &
RUN export DISPLAY=:1

ADD runscript.sh runscript.sh
CMD bash runscript.sh
