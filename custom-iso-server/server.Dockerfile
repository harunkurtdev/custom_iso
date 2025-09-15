FROM ubuntu:22.04
LABEL key="Custom ISO Server"

# Install Python3
RUN apt-get update && \
    apt-get install -y python3

# Create server directory and copy files
COPY ./files/user-data /server/
COPY ./files/meta-data /server/

# Set working directory
WORKDIR /server



# Run Python HTTP server
CMD [ "python3", "-m", "http.server", "3003" ]
