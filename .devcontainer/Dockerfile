# Pre-built Dev Container Image for R. More info: https://github.com/rocker-org/devcontainer-images/pkgs/container/devcontainer%2Ftidyverse
# Available R version: 4, 4.1, 4.0
ARG VARIANT="4.4"
FROM ghcr.io/rocker-org/devcontainer/r-ver:${VARIANT}

RUN install2.r --error --skipinstalled -n -1 \
        # pacotes R
        leontief \
        microbenchmark \
        Rdpack \
        emoji \
    && rm -rf /tmp/downloaded_packages

# Pacotes Python (digitar nomes em requirements.txt)
COPY requirements.txt /tmp/pip-tmp/
RUN python3 -m pip --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt

# install Rust
WORKDIR /home/
COPY . .
RUN bash ./setup_rust.sh
ENV PATH="/root/.cargo/bin:$PATH"
