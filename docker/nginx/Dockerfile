FROM nginx:mainline-alpine

WORKDIR /etc/nginx/templates

COPY ./conf/* ./

WORKDIR /etc/nginx/conf.d

RUN rm default.conf
