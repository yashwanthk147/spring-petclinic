FROM jenkins/agent
USER root
RUN apt-get update && apt-get install -y lsb-release ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -O https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz \
tar -xvzf apache-maven-3.8.8-bin.tar.gz
mv apache-maven-3.8.8 /opt/
M2_HOME='/opt/apache-maven-3.8.8/'
PATH="$M2_HOME/bin:$PATH"
export PATH
USER jenkins