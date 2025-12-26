FROM docker:20-dind

# Install Git
RUN apk add --no-cache git bash

# Copy the builder script
COPY builder.sh /usr/local/bin/builder.sh
RUN chmod +x /usr/local/bin/builder.sh

# Use ENTRYPOINT to run the script with arguments
ENTRYPOINT ["/usr/local/bin/builder.sh"]
