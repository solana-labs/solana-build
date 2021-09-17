FROM solanalabs/rust:1.54.0

ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

RUN sh -c "$(curl -sSfL https://release.solana.com/v1.7.11/install)"

RUN set -x \
 && apt update \
 && apt install -y jq

WORKDIR /build
COPY Cargo.toml .
COPY Cargo.lock .
COPY src src

RUN cargo build-bpf

RUN export PACKAGE=`cargo metadata --no-deps --format-version=1 | jq -r '.packages[0].name' | sed 's/-/_/g'` \
 && openssl dgst -sha256 -hex target/deploy/${PACKAGE}.so > target/deploy/${PACKAGE}-sha256.txt