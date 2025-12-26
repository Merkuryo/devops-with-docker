# Start from ubuntu:24.04
FROM ubuntu:24.04

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Copy the script file
COPY script.sh .

# Make the script executable
RUN chmod +x script.sh

# Set the script to run on container start
CMD ["./script.sh"]
