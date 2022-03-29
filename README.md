# nginx-spa

This Docker image acts as a wrapper to the official [nginx](https://hub.docker.com/_/nginx) docker image with some custom configurations created for Single-Page Apps (SPA) and file compression.

The intention is to be able to use this image out-of-the-box for any SPA. A common problem with SPAs is that when a user navigates directly to a deep-link, the base nginx config does not know how to provide the correct static files because to it the request path does not exist. The custom configuration packaged into this image is able to handle these situations gracefully.

Additionally, some SPAs offer the ability to host the application at a set baseURL (instead of https://example.com hosting the app, you must actually visit https://example.com/my-app). Under normal circumstances this becomes problematic because the SPA will request its static files at that baseURL so the Docker image must also be able to supply those files at that location. To make things simpler, this Docker image asks that all static files are copied into the same directory regardless of hosted-at status and instead provide a handy environment variable to allow for a proper rewrite.

## Usage

```dockerfile
FROM ghcr.io/dmsi-io/nginx-spa

COPY dist /usr/share/nginx/html
```

> `dist` refers to the directory that static files are located after a build process

### Hosted at Base URL

```dockerfile
FROM ghcr.io/dmsi-io/nginx-spa

ENV HOSTED_AT_BASE_URL="my-app"

COPY build /usr/share/nginx/html
```

> `my-app` refers to the "hosted-at" location that the client app expects to retrieve its files

> `build` refers to the directory that static files are located after a build process

## Custom Nginx Server

Since this Docker image is built on top of the standard Nginx Docker image, it comes packaged with some helpful features. The "hosted-at" option above is possible through server config templates.

Within this repo, [default.conf.template](templates/default.conf.template) holds the base server configuration for port 80. Within it, there is a rewrite rule that uses environment variable `${HOSTED_AT_BASE_URL}`. When the docker container is started, the first operation will use `envsubst` to substitute environment variables into all template files and move them under the `conf.d` directory with the `.template` extension removed. This process will allow these config files to be pulled in by the main [nginx.conf](nginx.conf) file as its server configurations.

If you would like to provide a custom server or overwrite the current default, create your own template file under the name of `<filename>.conf.template` and copy it into the `/etc/nginx/templates` directory at docker build time. The config must be at the server level to work properly.
