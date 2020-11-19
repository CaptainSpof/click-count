# TODO Make a build image
# TODO Use alpine

FROM tomcat:7.0

EXPOSE 8080

# Remove default test apps
RUN rm -fr /usr/local/tomcat/webapps/ROOT

# Copy our exploded app
COPY ./target/clickCount /usr/local/tomcat/webapps/ROOT
