#
# Configure the base operating system
#
# This is where we configure the very base level things. This stage
# would likely be inherited by any application of ours which
# runs on Ubuntu 20.04 and liekly won't need any additional changes.
#
FROM --platform=linux/amd64 ubuntu:20.04 as base

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    gcc \
    autoconf \
    automake \
    bison \
    libc6-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libsqlite3-dev \
    libtool \
    libyaml-dev \
    make \
    pkg-config \
    sqlite3 \
    zlib1g-dev \
    libgmp-dev \
    libreadline-dev \
    libssl-dev \
    gnupg2 \
    curl \
    sudo \
    git-core \
    htop \
    vim \
    unzip \
    bash-completion \
    ca-certificates

#
# Using the base operating system, configure the default user
# and anything they might need to set up the rest of the system.
#
# This sets up the main deveelopment user, configures it
# so that it doesn't need a password to run sudo commands,
# and sets up any gruop permissions.
#
# This stage will also likely not change, but if it does
# it won't be very often.
FROM base as user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd -r vscode && useradd -r -m -g vscode vscode -s /bin/bash
RUN usermod -aG sudo vscode
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vscode-nopasswd

#
# This stage installs node version manager and allows us to specify which
# version of nodejs we want to use.  Rails uses nodejs to build its
# assets.  This won't change, as we can configure the version from
# our compose file.
#
FROM user AS asdf
USER vscode
ARG RUBY_VERSION=
ARG NODE_VERSION=
ARG PYTHON_VERSION=
ARG GOLANG_VERSION=
ARG RUST_VERSION=
ARG ASDF_VERSION=0.14.0
ENV HOME /home/vscode
ENV ASDF_DIR $HOME/.asdf

RUN mkdir -p $ASDF_DIR && chown -R vscode:vscode $ASDF_DIR

RUN git clone https://github.com/asdf-vm/asdf.git $ASDF_DIR --branch v${ASDF_VERSION}
RUN echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc
RUN echo '. $HOME/.asdf/completions/asdf.bash' >> $HOME/.bashrc

# Source the asdf scripts
RUN . $HOME/.asdf/asdf.sh

# Install asdf plugins
RUN . $HOME/.asdf/asdf.sh && asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
RUN . $HOME/.asdf/asdf.sh && asdf plugin add python https://github.com/danhper/asdf-python.git
RUN . $HOME/.asdf/asdf.sh && asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
RUN . $HOME/.asdf/asdf.sh && asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
RUN . $HOME/.asdf/asdf.sh && asdf plugin add rust https://github.com/asdf-community/asdf-rust.git

RUN if [ ! -z "$RUBY_VERSION" ]; then \
      echo "Installing Ruby version ${RUBY_VERSION}" && \
      . $HOME/.asdf/asdf.sh && asdf install ruby ${RUBY_VERSION} && asdf global ruby ${RUBY_VERSION}; \
    fi

RUN if [ ! -z "$PYTHON_VERSION" ]; then \
      . $HOME/.asdf/asdf.sh && asdf install python ${PYTHON_VERSION} && asdf global python ${PYTHON_VERSION}; \
    fi

# # Install specific versions of nodejs, python, and ruby if specified
RUN if [ ! -z "$NODE_VERSION" ]; then \
      . $HOME/.asdf/asdf.sh && asdf install nodejs ${NODE_VERSION} && asdf global nodejs ${NODE_VERSION}; \
    fi

RUN if [ ! -z "$GOLANG_VERSION" ]; then \
      . $HOME/.asdf/asdf.sh && asdf install golang ${GOLANG_VERSION} && asdf global golang ${GOLANG_VERSION}; \
    fi

RUN if [ ! -z "$RUST_VERSION" ]; then \
      . $HOME/.asdf/asdf.sh && asdf install rust ${RUST_VERSION} && asdf global rust ${RUST_VERSION}; \
    fi

#
# This is the main stage of our devcontainer.  Here, we inherit the rvm build (which inherits nvm -> user -> base).
#
# This section contains two sections, a system-level section where all commands will be run and issued as
# the root user, and then a user-space section where any final user-specific configuration can happen. These commands
# will be run as the vscode/devcontainer user.
#
FROM asdf as devcontainer-apt

# We need to install tds for our specific app
RUN   export DEBIAN_FRONTEND=noninteractive && sudo apt-get update && \
      sudo apt-get install -y \
      telnet \
      openssh-client


# END SYSTEM LEVEL TWEAKS

FROM devcontainer-apt

USER vscode
SHELL [ "/bin/bash", "-l", "-c" ]
# --------------------------------
# BEGIN USER TWEAKS
# --------------------------------

# Some aliases to help with development
RUN echo "alias ga='git add -A'" >> /home/vscode/.bash_aliases
RUN echo "alias gc='git commit'" >> /home/vscode/.bash_aliases
RUN echo "alias gpo='git push origin'" >> /home/vscode/.bash_aliases
RUN git config --global --add safe.directory /workspace

# --------------------------------
# END USER TWEAKS
# --------------------------------

WORKDIR /workspace
