# TODO Make a build image

FROM tomcat:7.0

EXPOSE 8080

RUN rm -fr /usr/local/tomcat/webapps/ROOT
COPY ./target/clickCount /usr/local/tomcat/webapps/ROOT
