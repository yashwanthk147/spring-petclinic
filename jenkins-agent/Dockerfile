FROM jenkins/agent
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl unzip && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add docker group with GID 998 and add jenkins user to it
RUN groupadd -g 998 docker && \
    usermod -aG docker jenkins

RUN curl -O https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz && \
    tar -xvzf apache-maven-3.8.8-bin.tar.gz && \
    mv apache-maven-3.8.8 /opt/ && \
    rm apache-maven-3.8.8-bin.tar.gz

ENV M2_HOME=/opt/apache-maven-3.8.8 \
    PATH=/opt/apache-maven-3.8.8/bin:$PATH


# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip

USER jenkins