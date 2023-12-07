FROM ruby:2.4-stretch

WORKDIR /root

RUN wget --no-check-certificate https://dl.xpdfreader.com/xpdf-tools-linux-4.04.tar.gz -O - | tar -xz
ENV PATH=$PATH:/root/xpdf-tools-linux-4.04/bin64

WORKDIR /statements
# This can help when editing this file:
# COPY *.gemspec Gemfile /statements/
# COPY lib/ /statements/lib/
# RUN bundle install
COPY . /statements/
RUN bundle install

WORKDIR /wd
CMD ["ruby", "/statements/bin/statements"]
