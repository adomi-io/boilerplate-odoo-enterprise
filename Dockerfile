# This is the docker image we want to use as a base image
# If you have your own image, update the package url here
# By default, we will use the Adomi Odoo upstream image
#
# You can find the source code here:
# https://github.com/adomi-io/odoo
ARG ODOO_BASE_IMAGE="ghcr.io/adomi-io/odoo:19.0"
ARG ODOO_ENTERPRISE_REPOSITORY="https://github.com/odoo/enterprise"
ARG ODOO_ENTERPRISE_BRANCH="19.0"
ARG GIT_URL_FORMAT='https://x-access-token:%s@github.com\n'
ARG SPECIFIC_DATE=""
ARG SPECIFIC_HASH=""

FROM alpine:latest AS enterprise

ARG ODOO_ENTERPRISE_BRANCH
ARG ODOO_ENTERPRISE_REPOSITORY
ARG SPECIFIC_DATE
ARG SPECIFIC_HASH
ARG GIT_URL_FORMAT

RUN apk add --no-cache git

WORKDIR /tmp/enterprise

RUN --mount=type=secret,id=ODOO_ENTERPRISE_GITHUB_TOKEN,target=/run/secrets/ODOO_ENTERPRISE_GITHUB_TOKEN,uid=0,gid=0,required=true \
    set -eu; \
    CREDS_FILE="$(mktemp)"; \
    trap 'rm -f "${CREDS_FILE}"' EXIT; \
    TOKEN="$(cat /run/secrets/ODOO_ENTERPRISE_GITHUB_TOKEN)"; \
    test -n "${TOKEN}"; \
    printf "${GIT_URL_FORMAT}" "${TOKEN}" > "${CREDS_FILE}"; \
    git -c "credential.helper=store --file=${CREDS_FILE}" \
        -c credential.useHttpPath=false \
        -c core.askPass=/bin/true \
        -c credential.https://github.com.useHttpPath=false \
        init .; \
    git -c "credential.helper=store --file=${CREDS_FILE}" \
        -c credential.useHttpPath=false \
        -c core.askPass=/bin/true \
        -c credential.https://github.com.useHttpPath=false \
        remote add origin "${ODOO_ENTERPRISE_REPOSITORY}"; \
    if [ -n "${SPECIFIC_HASH:-}" ]; then \
        git -c "credential.helper=store --file=${CREDS_FILE}" \
            -c credential.useHttpPath=false \
            -c core.askPass=/bin/true \
            -c credential.https://github.com.useHttpPath=false \
            fetch --depth 1 origin "${SPECIFIC_HASH}"; \
        git checkout FETCH_HEAD; \
    elif [ -n "${SPECIFIC_DATE:-}" ]; then \
        git -c "credential.helper=store --file=${CREDS_FILE}" \
            -c credential.useHttpPath=false \
            -c core.askPass=/bin/true \
            -c credential.https://github.com.useHttpPath=false \
            fetch origin "${ODOO_ENTERPRISE_BRANCH}"; \
        REV_HASH="$(git rev-list -n 1 --before="${SPECIFIC_DATE}" FETCH_HEAD)"; \
        test -n "${REV_HASH}"; \
        git checkout "${REV_HASH}"; \
    else \
        git -c "credential.helper=store --file=${CREDS_FILE}" \
            -c credential.useHttpPath=false \
            -c core.askPass=/bin/true \
            -c credential.https://github.com.useHttpPath=false \
            fetch --depth 1 origin "${ODOO_ENTERPRISE_BRANCH}"; \
        git checkout FETCH_HEAD; \
    fi; \
    rm -rf .git

RUN git clone \
    --depth 1 \
    --branch "${ODOO_ENTERPRISE_BRANCH}"\
    https://github.com/odoo/design-themes.git \
    /tmp/design-themes \
    && cp -a \
    /tmp/design-themes/theme_* \
    /tmp/enterprise/

FROM ${ODOO_BASE_IMAGE} AS configuration_layer

# Set user to root so we can install dependencies
USER root

# Fail the build if any command in a RUN step fails
SHELL ["/bin/bash", "-xeo", "pipefail", "-c"]

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libxml2 \
    libxmlsec1t64 \
    libxmlsec1t64-openssl; \
    rm -rf /var/lib/apt/lists/*

# Here, you can install python dependencies
# For example:
RUN pip install \
    xmlsec~=1.3 \
    lxml~=6.0 \
    phonenumbers \
    google-auth \
    packaging
#    python-slugify  \
#    stripe  \
#    mailerlite  \
#    mailerlite \
#    pika \
#    betterproto \
#    typeform \
#    meilisearch

# Verify xmlsec and lxml were built against the same libxml2
RUN python -c "import lxml.etree, xmlsec"

# Extend the layer with our python dependencies installed
FROM configuration_layer

# Odoo will run as a non-root user
# UID 1000 is the default user for Ubuntu
USER ubuntu

# We will work in the volumes directory, where our addons
# and mounted files are located
WORKDIR /volumes

# Copy our enterprise repo
COPY --from=enterprise /tmp/enterprise /volumes/enterprise

# Copy your configuration into the container
COPY config/odoo.conf /volumes/config/odoo.conf

# Copy extra addons for downstream images
COPY extra_addons /volumes/extra_addons

# Copy your custom addons into the container
COPY addons /volumes/addons
