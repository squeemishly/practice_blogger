# Update the Host

## Problem Description

Here's a replay of what's on the main ReadMe:

In a request to an origin server, Fastly will pass along the Host domain from the request. So if you bought `www.example.com` and you run that through Fastly, we will send that to the origin to find the object we're looking for. Unfortunately, Heroku doesn't know anything about `www.example.com`, so we'll get back a generic "This content has not been created yet" message from Heroku. We need to tell Heroku the domain it knows about, e.g. `salty-lake-12345.herokuapp.com`.

## Test the Problem

Visit the domain you purchased. You should see an error message from Heroku: `There's nothing here, yet. Build something amazing`. If you don't see your app yet, Heroku doesn't know where to direct your request.

## Documentation to Solve the Problem

[Using the Host Override in the UI](https://docs.fastly.com/guides/basic-configuration/specifying-an-override-host) is definitely the easiest way to solve this problem. However, that comes with a few possible downsides, especially when you start implementing [shielding](https://docs.fastly.com/guides/performance-tuning/shielding). Remember, the cache key is made up of the Host header and the request URL.

Consider overriding the host in `vcl_miss` and `vcl_pass`. Remember, the only time we need to change the host header is when the request is going back to Heroku. When a request is routed to origin, it will always go through either `vcl_miss` or `vcl_pass`, so changing the Host header there would only change it for Heroku's benefit, not on Fastly, which would keep our cache key the same between POPs.

**HINT:** One thing to keep in mind when experimenting with this is the different variables you have access to in your subroutines. While you _can_ update the request, `req.` header, look into how `bereq.` would behave in these subroutines. You can create the required code using [VCL Snippets](https://docs.fastly.com/vcl/vcl-snippets/using-regular-vcl-snippets/).

## One Possible Solution

Please try to implement a solution before revealing the possible solution below. This answer is just one possible solution. If you got your app working one way, try sticking with that way and see where problems may come up. This can help you troubleshoot other issues better in the future.

<details><summary>Reveal a Possible Solution</summary>
We can change the Host header only on requests that are sent to our backend. Try adding the following code to both `vcl_miss` and `vcl_pass`.

```perl
if (req.backend == F_heroku) {
  set bereq.http.host = "salty-lake-12345.herokuapp.com";
}
```

Clearly, you will need to change this code block so `F_heroku` matches your origin name on Fastly and `salty-lake-12345.herokuapp.com` to your URL on Heroku.
</details>

## Super Secret Awesome Knowledge

<details><summary>Reveal the Knows</summary>
One other option is to `unset` the Host header on backend requests. As long as you identify the domain of the app when you create the backend, i.e. you use `salty-lake-12345.herokuapp.com` and not some Heroku IP, that information is in the description of the backend. If there is no Host header defined, Fastly will use the Host defined when creating the backend.

If you want to play with this, try adding the following code block to `vcl_miss` and `vcl_pass`:

```perl
unset bereq.http.host;
```

Why do you think I'm unsetting the `bereq` Host and not the `req` Host?
</details>
