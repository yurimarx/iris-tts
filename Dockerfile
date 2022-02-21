FROM intersystemsdc/iris-community

USER root

ENV DEBIAN_FRONTEND noninteractive


# install libraries required to gTTS to process TTS
RUN apt-get -y update \
    && apt-get -y install apt-utils \
    && apt-get install -y build-essential unzip pkg-config wget \
    && apt-get install -y python3-pip   

# use pip3 (the python zpm) to install gTTS dependencies
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install --target /usr/irissys/mgr/python gTTS

USER root   
WORKDIR /opt/irisbuild
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisbuild
USER ${ISC_PACKAGE_MGRUSER}

WORKDIR /opt/irisbuild
COPY  src src
COPY Installer.cls Installer.cls
COPY module.xml module.xml
COPY iris.script iris.script

USER ${ISC_PACKAGE_MGRUSER}

RUN iris start IRIS \
	&& iris session IRIS < iris.script \
    && iris stop IRIS quietly
