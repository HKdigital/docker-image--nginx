# How it works
 
When a request arrives at the NGINX webserver, `maps` are used to determine if the request should be prerendered.

Requests should be prerendered if:
 - The user agent identifies itself as a bot
 - The request is for a webpage, not another resource like an image for example

An example of doing a request like a bot:
(in this case the user agent is set to "GoogleBot")

```bash
curl https://www.mywebsite.dev -A GoogleBot
curl https://www.mywebsite.dev/home -A GoogleBot
curl https://www.mywebsite.dev/index.html -A GoogleBot
```

When the request has been proxied to the `prerender` service (container), the service requests the same url, renders the content and returns it.

@note that the `prerender` service must be able to request the original url, so url's like `localhost` won't work.
