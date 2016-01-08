# 本体
#
# VERSION               0.0.1

FROM      gendosu/ubuntu-ruby:2.2.4

MAINTAINER Gen Takahashi "gendosu@gmail.com"

RUN apt-get update \
&&  apt-get -y upgrade \
&&  apt-get -y --force-yes install \
  ttf-kochi-gothic \
  imagemagick \
  language-pack-ja \
  fonts-migmix

RUN mkdir -p /products
WORKDIR /products

ADD Gemfile /products/Gemfile
ADD Gemfile.lock /products/Gemfile.lock

RUN eval "$(rbenv init -)"; bundle
