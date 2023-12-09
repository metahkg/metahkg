FROM nginx:1.25.3-alpine

WORKDIR /etc/nginx/templates

COPY ./conf/* ./

WORKDIR /etc/nginx/conf.d

RUN rm default.conf
