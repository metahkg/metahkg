FROM nginx:1.25.1-alpine

WORKDIR /etc/nginx/templates

COPY ./conf/* ./

WORKDIR /etc/nginx/conf.d

RUN rm default.conf
