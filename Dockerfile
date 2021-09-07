FROM solanalabs/rust:1.54.0

ENV HOME="/root"
ENV PATH="${HOME}/.local/share/solana/install/active_release/bin:${PATH}"

RUN sh -c "$(curl -sSfL https://release.solana.com/v1.7.11/install)"

WORKDIR /build
COPY . .

RUN cargo build-bpf