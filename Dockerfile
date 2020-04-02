FROM ubuntu:latest

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update \
	&& apt-get -y install curl wget git lsb-release sudo python \
	&& rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf > rustup.sh \
	&& chmod +x rustup.sh \
	&& ./rustup.sh -y \
	&& rm rustup.sh
ENV PATH "/root/.cargo/bin:${PATH}"

RUN rustup target list | grep android | xargs rustup target add
WORKDIR /rusty_v8

RUN git init \
	&& git remote add origin https://github.com/gponsinet/rusty_v8.git \
	&& git fetch origin \
	&& git checkout android_support_from_scratch \
	&& git submodule update --init --recursive
ENV PATH "/rusty_v8/tools/depot_tools:${PATH}"


RUN gclient sync

RUN \
	DEBIAN_FRONTEND=noninteractive \
	apt-get update && apt-get -y install lsb-release sudo python \
	&& ./v8/build/install-build-deps-android.sh \
	&& rm -rf /var/lib/apt/lists/*

COPY . /rusty_v8
