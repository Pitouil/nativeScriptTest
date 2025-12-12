FROM ubuntu:22.04

# Éviter les prompts interactifs
ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    PATH=/opt/android-sdk/cmdline-tools/tools/bin:/opt/android-sdk/platform-tools:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Update et installation des dépendances système
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core tools
    curl \
    wget \
    git \
    unzip \
    zip \
    build-essential \
    # Java
    openjdk-17-jdk-headless \
    # Python (requis par certains outils Android)
    python3 \
    # USB tools (pour devices physiques)
    usbutils \
    # Autres
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Node.js & npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g npm@latest

# NativeScript CLI global
RUN npm install -g nativescript && \
    ns error-reporting disable && \
    ns usage-reporting disable

# Android SDK setup
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd /tmp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip && \
    unzip -q commandlinetools-linux-10406996_latest.zip && \
    mv cmdline-tools $ANDROID_HOME/cmdline-tools/tools && \
    rm commandlinetools-linux-10406996_latest.zip && \
    cd $ANDROID_HOME/cmdline-tools/tools/bin && \
    yes | ./sdkmanager --licenses > /dev/null 2>&1 || true && \
    ./sdkmanager "platform-tools" \
      "platforms;android-35" \
      "build-tools;35.0.0" \
      "extras;android;m2repository" \
      "extras;google;m2repository" \
      > /dev/null 2>&1

# Dossier de travail
WORKDIR /app

# Installation des dépendances de développement locale (optionnel au build)
# RUN npm install

# Shell par défaut
CMD ["/bin/bash"]
