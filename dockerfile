# Use Python 3.8 as the base image
FROM python:3.8-slim

# Set the working directory
WORKDIR /workspace

# Install Terraform, Google Cloud SDK, and Nano editor
RUN apt-get update -y && \
    apt-get install -y wget unzip gcc python3-dev nano && \
    wget https://releases.hashicorp.com/terraform/YOUR_TERRAFORM_VERSION/terraform_YOUR_TERRAFORM_VERSION_linux_amd64.zip && \
    unzip terraform_YOUR_TERRAFORM_VERSION_linux_amd64.zip -d /usr/local/bin/ && \
    rm terraform_YOUR_TERRAFORM_VERSION_linux_amd64.zip && \
    wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz && \
    tar zxvf google-cloud-sdk.tar.gz && \
    ./google-cloud-sdk/install.sh -q && \
    rm google-cloud-sdk.tar.gz && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Add Google Cloud SDK to the PATH
ENV PATH $PATH:/workspace/google-cloud-sdk/bin

# Copy the entire project to /workspace
COPY . /workspace/

# Install dependencies
RUN pip install --no-cache-dir -e . 
RUN pip install --no-cache-dir 'apache-beam[gcp]'==YOUR_APACHE_BEAM_VERSION protobuf==YOUR_PROTOBUF_VERSION

# Set the command to be executed when the container is run
CMD ["python", "main_pipeline.py"]