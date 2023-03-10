FROM timbru31/java-node
#LABEL org.opencontainers.image.source = "https://github.com/netwerk-digitaal-erfgoed/modemuze-pipeline"
RUN rm /etc/localtime 
RUN ln -s /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
WORKDIR /app
RUN curl -L https://dlcdn.apache.org/jena/binaries/apache-jena-4.7.0.tar.gz -o ./apache-jena-4.7.0.tar.gz
RUN tar xfz apache-jena-4.7.0.tar.gz
RUN mv apache-jena-4.7.0 apache-jena
RUN rm -rf apache-jena-4.7.0.tar.gz
ENV JENA_HOME=/app/apache-jena
ENV PATH=$PATH:$JENA_HOME/bin:/app/bin
RUN mkdir bin
RUN curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o ./bin/jq
RUN chmod 755 bin/jq
COPY bin/* bin/
COPY mappings/ mappings/
COPY data/ data/
COPY src/ src/
COPY ./package.json .
RUN npm install