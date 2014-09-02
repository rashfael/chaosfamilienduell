FROM dockerfile/nodejs

ADD . /src

WORKDIR /src

RUN npm -g install coffee-script brunch bower forever
RUN cake install

VOLUME ["/data"]
ENV DATADIR /data/

EXPOSE 9000
CMD cake run