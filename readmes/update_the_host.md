# Update the Host

## Problem Description

Here's a replay of what's on the main ReadMe:

In a request to an origin server, Fastly will pass along the Host domain from the request. So if you bought `www.example.com` and you run that through Fastly, we will send that to the origin to find the object we're looking for. Unfortunately, Heroku doesn't know anything about `www.example.com`, so we'll get back a generic "This content has not been created yet" message from Heroku. We need to tell Heroku the domain it knows about, e.g. `salty-lake-12345.herokuapp.com`.

## Test the Problem

Visit the domain you purchased. You should see an error message from Heroku: `There's nothing here, yet. Build something amazing`. If you don't see your app yet, Heroku doesn't know where to direct your request.

## Documentation to Solve the Problem

[Using the Host Override in the UI](https://docs.fastly.com/guides/basic-configuration/specifying-an-override-host) is definitely the easiest way to solve this problem. However, that comes with a few possible downsides, including potential errors if you have more than one backend, which we will have before we finish getting this app fully up and running on Fastly.

Consider overriding the host in `vcl_miss` and `vcl_pass`. One thing to keep in mind when experimenting with this is the different variables you have access to in your subroutines. While you _can_ update the request, `req.` header, look into how `bereq.` would behave in these subroutines.

## One Possible Solution

<details><summary>Reveal a Possible Solution</summary>
My Solution

```perl
if (req.backend == F_heroku) {
  set bereq.http.host = "salty-lake-12345.herokuapp.com";
}
```
</details>

## Super Secret Awesome Knowledge
