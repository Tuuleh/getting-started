# Install the base requirements for the app.
# This stage is to support development.
FROM python:alpine AS base
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

FROM node:12-alpine AS app-base
WORKDIR /app
COPY app/package.json app/yarn.lock ./
COPY app/spec ./spec
COPY app/src ./src

# Run tests to validate app
FROM app-base AS test
RUN apk add --no-cache python3 g++ make
RUN yarn install
RUN yarn test

# Clear out the node_modules and create the zip
FROM app-base AS app-zip-creator
COPY app/package.json app/yarn.lock ./
COPY app/spec ./spec
COPY app/src ./src
RUN apk add zip && \
    zip -r /app.zip /app

# Run a NodeJS server and expose port 8000
FROM base
COPY . .
EXPOSE 8000
CMD ["mkdocs", "serve", "-a", "0.0.0.0:8000"]
