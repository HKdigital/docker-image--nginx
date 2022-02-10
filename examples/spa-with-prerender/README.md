# How it works
 
When a request arrives at the NGINX webserver, NGINX `maps` are used to determine if the request should be prerendered.

Requests should be prerendered if:
 - The user agent identifies itself as a bot
 - The request is for a `webpage` (html), other resources like images for example should not be prerendered

## Prerender source

When the request has been proxied to the `prerender` service (container), the `prerender` service will request the same url from the webserver, render the content and return the rendered result.

The `prerender` service must be able to request the original url, so url's like `localhost` usually won't work (e.g. when using docker).

In the config file `prerender_source.conf` you can specify the url that the prerender service should use.

## Make a test request using `curl`

An example of doing a request like a bot:
(in this case the user agent is set to "GoogleBot")

```bash
curl https://www.mywebsite.dev -A GoogleBot
curl https://www.mywebsite.dev/home -A GoogleBot
curl https://www.mywebsite.dev/index.html -A GoogleBot
```
