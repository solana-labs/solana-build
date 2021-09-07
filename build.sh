docker build -t solana-build .

CONTAINER_ID=`docker create solana-build`

docker cp $CONTAINER_ID:/build/target/deploy/bpf_program_template.so bpf_program_template.so

docker rm -v $CONTAINER_ID