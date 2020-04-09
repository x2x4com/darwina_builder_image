FROM debian:stable-slim
MAINTAINER EvolutionLand x2x4com@gmail.com

COPY sources.list /etc/apt/sources.list
RUN apt-get update && apt-get -y install curl cmake pkg-config libssl-dev git clang libclang-dev && apt-get clean
RUN mkdir /root/.cargo
COPY cargo_config /root/.cargo/config
ENV RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"
ENV RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup update nightly
RUN rustup target add wasm32-unknown-unknown --toolchain nightly
RUN rustup update stable
RUN RUST_LOG=cargo=debug cargo install --verbose --git https://github.com/alexcrichton/wasm-gc
