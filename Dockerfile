# FROM node:lts-alpine3.21
FROM registry.access.redhat.com/ubi8/nodejs-18:latest

# Create app directory
WORKDIR /usr/src/app

# Adjust permissions for non-root user
USER root
RUN chown -R 1001:0 /usr/src/app

# Install app dependencies (only production dependencies)
COPY package*.json ./

# RUN npm install
# If you are building your code for production
RUN npm ci --only=production

# Bundle app source
COPY . .

# Set permissions for non-root user after copying the files
RUN chown -R 1001:0 /usr/src/app

# Switch to the non-root user for better security
USER 1001

# Expose port 8080 for the application
EXPOSE 8080

# Set the entrypoint to start the app using npm
CMD [ "npm", "start" ]