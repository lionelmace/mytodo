FROM registry.access.redhat.com/ubi9/nodejs-22-minimal:latest
# FROM registry.access.redhat.com/ubi9/nodejs-22:latest

# Create app directory
WORKDIR /usr/src/app

# Adjust permissions for non-root user
USER root
RUN chown -R 1001:0 /usr/src/app

# Install app dependencies (only production dependencies)
COPY package*.json ./

# RUN npm install
RUN npm ci --omit=dev
# If you are building your code for production
# RUN npm ci --only=production

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