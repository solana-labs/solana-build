# Exit on any error
set -e

# Print statements as they are run
set -x

# Set the remote public (e.g. Docker Hub) repository where the image will be located (value passed as a CLI arg or something)
export REMOTE_REPO=docker.io/jordansexton/

# Get the name of the package from Cargo.toml and transform it to a filename
export PACKAGE_NAME=`cargo metadata --no-deps --format-version=1 | jq -r '.packages[0].name' | sed 's/-/_/g'` \

# Tag the image as latest
export LOCAL_IMAGE=${PACKAGE_NAME}:latest

# Build the image
docker build -t $IMAGE .

# Get the sha256 hash of the image from the ID
export IMAGE_HASH=`docker images --no-trunc --quiet $IMAGE | cut -d':' -f2`

# The final name of the image that will be stored on chain in the ELF file
export REMOTE_IMAGE=${REMOTE_REPO}${PACKAGE_NAME}:${IMAGE_HASH}

# Tag the latest built image with the hashed remote tag
docker image tag $PACKAGE_NAME $REMOTE_IMAGE

# Push the hashed tag
docker push $REMOTE_IMAGE

# Create a container from the image
export CONTAINER=`docker create $IMAGE`

# Set the build output directory
export DIRECTORY=target/deploy

# Clear the build output directory
rm -rf ${DIRECTORY}/*

# Copy the build from the container to local filesystem
docker cp ${CONTAINER}:/build/${DIRECTORY}/. ${DIRECTORY}/

# Read the hash of the ELF file
export ELF_HASH=`cat ${DIRECTORY}/${PACKAGE_NAME}-sha256.txt`

# Append the hashes to the ELF file (this should be replaced with something smarter)
echo -e "\n${ELF_HASH}\n${REMOTE_IMAGE}" >> ${DIRECTORY}/${PACKAGE_NAME}.so

# Optionally, save the docker image to a file (could be stored on arweave as a backup of the Docker repo)
# docker save $IMAGE | gzip > ${PACKAGE_NAME}.tar.gz