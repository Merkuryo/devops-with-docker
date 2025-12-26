FROM node:20

WORKDIR /usr/src/app

# Copy package files
COPY package* ./

# Install dependencies
RUN npm install

# No COPY of source code here - we'll use bind mount for development
# This allows hot-reload when files change

CMD ["npm", "start"]
