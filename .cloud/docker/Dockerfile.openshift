# Catalog: https://access.redhat.com/containers/?tab=tech-details#/registry.access.redhat.com/ubi8/nodejs-10
#
# docker login registry.redhat.io
#   Username: ${REGISTRY-SERVICE-ACCOUNT-USERNAME}
#   Password: ${REGISTRY-SERVICE-ACCOUNT-PASSWORD}
# Login Succeeded!
# 
# docker pull registry.redhat.io/ubi8/ubi
# docker build . --file openshift/Dockerfile -t ${IBM-CLOUD-REGISTRY}/${NAMESPACE}/${IMG-NAME}:${IMG-TAG}

FROM registry.redhat.io/ubi8/nodejs-10

# Create app directory
USER root
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
RUN npm install

# Bundle app source
COPY . /usr/src/app

EXPOSE 8080
CMD [ "npm", "start" ]