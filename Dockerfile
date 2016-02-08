FROM debian:latest

MAINTAINER Bakudankun <bakudankun@gmail.com>

ENV RICTY_VERSION 4.0.1
ENV MIGU_VERSION 20150712
ENV MIGU_RELEASE_ID 63545

RUN apt-get update \
	&& apt-get install -y curl zip unzip fontforge \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -SL https://github.com/yascentur/Ricty/archive/${RICTY_VERSION}.tar.gz \
	| tar -xz \
	&& mkdir -p Ricty-${RICTY_VERSION}/LICENSE \
	&& curl -o migu.zip -SL http://osdn.jp/frs/redir.php?f=%2Fmix-mplus-ipa%2F${MIGU_RELEASE_ID}%2Fmigu-1m-${MIGU_VERSION}.zip \
	&& unzip migu.zip && rm migu.zip \
	&& mv migu-1m-${MIGU_VERSION}/* Ricty-${RICTY_VERSION} \
	&& mv Ricty-${RICTY_VERSION}/ipag* Ricty-${RICTY_VERSION}/mplus* Ricty-${RICTY_VERSION}/migu-README.txt Ricty-${RICTY_VERSION}/LICENSE \
	&& rm -r migu-1m-${MIGU_VERSION} \
	&& curl -o Ricty-${RICTY_VERSION}/Inconsolata-Regular.ttf -SL https://github.com/google/fonts/raw/master/ofl/inconsolata/Inconsolata-Regular.ttf \
	&& curl -o Ricty-${RICTY_VERSION}/Inconsolata-Bold.ttf -SL https://github.com/google/fonts/raw/master/ofl/inconsolata/Inconsolata-Bold.ttf \
	&& mkdir Ricty-${RICTY_VERSION}/LICENSE/Inconsolata \
	&& curl -o Ricty-${RICTY_VERSION}/LICENSE/Inconsolata/OFL.txt -SL https://github.com/google/fonts/raw/master/ofl/inconsolata/OFL.txt

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
