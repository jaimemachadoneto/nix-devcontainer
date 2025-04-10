ARG USER=vscode
ARG UID=1000
ARG GID=${UID}

FROM debian:bookworm-slim as base

ARG USER
ARG UID
ARG GID
ARG NIX_INSTALLER=https://nixos.org/nix/install

# Set shell and check for pipe fails
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install deps required by Nix installer
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    xz-utils

# Create user
RUN groupadd -g ${GID} ${USER} && \
    useradd -u ${UID} -g ${GID} -G sudo -m ${USER} -s /bin/bash

# Configure sudo and Nix
RUN sed -i 's/%sudo.*ALL/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers && \
    echo "sandbox = false" > /etc/nix.conf && \
    echo "experimental-features = nix-command flakes" >> /etc/nix.conf

# Install Nix and enable flakes
USER ${USER}
ENV USER=${USER}
ENV NIX_PATH=/home/${USER}/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
ENV NIX_CONF_DIR /etc
RUN curl -L ${NIX_INSTALLER} | NIX_INSTALLER_NO_MODIFY_PROFILE=1 sh


RUN . /home/${USER}/.nix-profile/etc/profile.d/nix.sh && \
    nix-env --set-flag priority 10 nix-2.28.1




FROM debian:bookworm-slim

ARG USER
ARG UID
ARG GID


ENV NIX_CONF_DIR /etc
ENV DIRENV_CONFIG /etc

## Install vscode deps
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    gnupg \
    locales \
    ssh \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -g ${GID} ${USER} && \
    useradd -u ${UID} -g ${GID} -G sudo -m ${USER} -s /bin/bash
# Copy nix and configs
COPY --from=base --chown=${USER}:${USER} /nix /nix
COPY --from=base /etc/nix.conf /etc/nix.conf
COPY --from=base --chown=${USER}:${USER} /home/${USER} /home/${USER}


# Configure en_US.UTF-8 locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Configure sudo
RUN sed -i 's/%sudo.*ALL/%sudo   ALL=(ALL:ALL) NOPASSWD:ALL/' /etc/sudoers

# # Setup Nix environment
RUN echo "source /home/${USER}/.nix-profile/etc/profile.d/nix.sh" >> /etc/bash.bashrc && \
    echo "source /home/${USER}/.nix-profile/etc/profile.d/nix.sh" >> /etc/zshrc

RUN mkdir -p /go && chown -R ${USER}:${USER} /go

USER ${USER}

# Setup vscode
RUN mkdir -p /home/${USER}/.vscode-server/ && \
    mkdir -p /home/${USER}/.vscode-server-insiders/

# Copy configs
RUN mkdir -p /home/${USER}/.config/devcontainer/extra
COPY --chown=${USER}:${USER} ./ /home/${USER}/.config/devcontainer/

# Build home-manager
WORKDIR /home/${USER}/.config/devcontainer

ENV USER=${USER}
RUN . /home/${USER}/.nix-profile/etc/profile.d/nix.sh && \
    nix-env --set-flag priority 10 nix-2.28.1 && \
    mkdir -p /nix/var/nix/profiles/per-user/${USER} && \
    mkdir -p /nix/var/nix/gcroots/per-user/vscode/ && \
    nix run --show-trace .#activate ${USER}@ && \
    nix-collect-garbage -d

# Copy entrypoint
COPY --chown=${USER}:${USER} docker-entrypoint.sh /docker-entrypoint.sh

# Check if zsh exists before running zplug update
RUN if [ -f "/home/${USER}/.nix-profile/bin/zsh" ]; then \
    /home/${USER}/.nix-profile/bin/zsh -ic 'source ~/.zshrc && zplug update'; \
    else \
    echo "zsh not found, skipping zplug update"; \
    fi

ENTRYPOINT [ "/docker-entrypoint.sh" ]