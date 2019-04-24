# Heroku Timeouts

## Problem Description

Heroku doesn't just keep your app up and running all the time. Instead, if it hasn't been hit with any requests for some period, it gets unloaded from the server memory. On the first hit it gets loaded and stays loaded until some time passes without anyone accessing it. However, if your app hasn't been hit in a while, the connection might timeout because Fastly hasn't received any data. This will return an ugly page with no information to the end user with a 503 response. Ew.

## Test the Problem

### In the Browser

If you haven't visited your app in a while, go to your domain and watch the wheels spin for a minute. Then see an ugly page load with the following content:

```perl
Error 503 first byte timeout
first byte timeout

Guru Mediation:
Details: cache-den19626-DEN 1556063235 2558945834

Varnish cache server
```

### Via curl

If you haven't visited your app in a while, run `curl <your_domain>` and watch the wheels spin for a minute. The return will be a simple HTML document with the following text:

```perl
<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
 "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>503 first byte timeout</title>
  </head>
  <body>
    <h1>Error 503 first byte timeout</h1>
    <p>first byte timeout</p>
    <h3>Guru Mediation:</h3>
    <p>Details: cache-den19625-DEN 1556063174 3049308233</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
```

## Documentation to Solve the Problem

[Kaffeine](https://kaffeine.herokuapp.com/) is an app on Heroku that will ping your app and make sure that you don't get these timeouts. Which is neat, but let's solve this problem using Fastly.

One option is to create a [custom response on 503 errors](https://docs.fastly.com/guides/basic-configuration/creating-error-pages-with-custom-responses#creating-error-pages-for-404-and-503-errors). This way, you can use HTML to send a message back to your users, so instead of that ugly `Guru Meditation` message, your user can be told that `We're currently compiling the best blogs for you. Please refresh and you'll see the best the world has to offer`. Or something. If you would rather handroll your 503 response, check out [this community post on vcl_error](https://support.fastly.com/hc/en-us/community/posts/360040168631-How-Does-vcl-error-Work-) for a hint on how you could do this.

But what if the user never has to see the error to begin with? Another option is to increase the [First Byte Timeout](https://docs.fastly.com/guides/debugging/changing-connection-timeouts-to-your-origin) on your origin. Increasing this will give Heroku time to boot up your app and send a response before Fastly errors out.

Another option is to look into [serving stale content](https://docs.fastly.com/guides/performance-tuning/serving-stale-content). As long as we still have the object in cache and the TTL of the stale state hasn't been passed, Fastly can serve a stale content back to your end user. Please note that this does require the object to still be in cache. So if the object has been evicted, or [any of a batch of other conditions are met](https://docs.fastly.com/guides/performance-tuning/serving-stale-content#why-serving-stale-content-may-not-work-as-expected), Fastly won't be able to serve the stale content back to the end user.

[Return Home](https://github.com/squeemishly/practice_blogger)
