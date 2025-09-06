FROM mcr.microsoft.com/playwright:v1.54.2-jammy

RUN npm install -g netlify-cli node-jq serve \
    && apt-get update \
    && apt-get install -y jq \
    && rm -rf /var/lib/apt/lists
