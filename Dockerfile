FROM ruby:2.6.6

RUN apt-get update

WORKDIR /talking

COPY . .

VOLUME [ "/talking" ]

RUN gem install rails

RUN cd /talking

RUN ["rm","-f","Gemfile.lock"]

CMD ["bash","/talking/boot.sh"]
