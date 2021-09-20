FROM solanalabs/rust:1.54.0

RUN curl -sSfL "https://release.solana.com/v1.7.11/install" | sh
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

RUN set -x \
 && apt update \
 && apt install -y jq

WORKDIR /build
COPY Cargo.toml .
COPY Cargo.lock .
COPY src src

RUN cargo build-bpf

RUN set -e \
 && export PACKAGE=`cargo metadata --no-deps --format-version=1 | jq -r '.packages[0].name' | sed 's/-/_/g'` \
 && export FILE=`target/deploy/${PACKAGE}.so` \
 && export HASH=`openssl dgst -sha256 $FILE | cut -d' ' -f2` \
 && echo $HASH > target/deploy/${PACKAGE}-sha256.txt