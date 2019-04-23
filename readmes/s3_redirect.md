# Redirect From S3

## Problem Description

As was [mentioned in the setup of this app](https://github.com/squeemishly/practice_blogger/tree/create-problem-descriptions#aws-bucket), user profile photos are stored in an S3 bucket. So a request comes in for the `/articles` page, and on that page, there are thumbnails of the author of each article. When the browser receives the HTML document, it will issue another request for each of the images on the page. The request comes into Fastly, which will forward the request to our Heroku app. Our app will then see that the images are not stored on Heroku, and will respond with a 302 to our S3 bucket. This 302 is then sent back to the browser, who will make the request to S3 directly, bypassing Fastly entirely! Which means Fastly only caches the 302 response and not the image. That's not helpful at all!!!

## Test the Problem

### In the Browser

Open the `Inspect` panel in Google Chrome and go to the `Network` tab, then visit your domain. You'll see each of the assets as they load on the page. You'll notice that the browser makes one request for an image, `wonder-woman.jpg`, and the status of that request is 302. Then, shortly below that, you'll see a random hash as a title with a status of 200. If you click on that hash, you'll see the request URL is pointing to your S3 bucket, not your Fastly domain.  

![S3 Redirects In the Network Tab](https://github.com/squeemishly/practice_blogger/blob/master/app/assets/images/app_screenshots/S3_Redirects.png)

What we need is to catch the redirect served back from Heroku that points to your S3 bucket. Once we catch it, we want to go to your S3 bucket, retrieve the image, and then cache it on Fastly under _the same URL and host as the request came in with_.

If you already fixed the [redirect from Heroku](heroku_redirect.md), you'll already have some idea of how you could approach this problem.

### Via curl

Open the `Inspect` panel in Google Chrome and go to the `Network` tab, then visit your domain. You'll see each of the assets as they load on the page. You'll notice that the browser makes one request for an image, say `wonder-woman.jpg`. If you right click on the image title, hover over the `Copy` menu, then select `Copy as cURL`, you can have the browser generated curl to run:

![copy a request curl](https://github.com/squeemishly/practice_blogger/blob/master/app/assets/images/app_screenshots/copy-curl.png)

Open your terminal and paste in the curl. Add `-I` to the end of the curl so we can see the object headers instead of the HTML return. Your response will be a 302 and will contain a `Location` header:

```
HTTP/1.1 302 Found
Location: <your-S3-backend-with-a-bunch-of-qs-content>
```

When this works correctly, we should see a 200 response.

## Documentation to Solve the Problem

[Following redirects to S3 objects and caching S3 responses](https://docs.fastly.com/guides/integrations/amazon-s3#following-redirects-to-s3-objects-and-caching-s3-responses) can guide you through this process. As a summary, here's what you'll need to accomplish:

1. Catch the redirect pointing to S3 coming back from Heroku
1. Store the URL (everything after the `.com` in the `Location` header) in a vanity header
1. Restart the request
1. Set your backend to point to S3
1. Update your `Host` and `URL` so S3 knows what to look for

**HINT:** You'll need to [setup a backend for S3](https://docs.fastly.com/guides/basic-configuration/connecting-to-origins) that Fastly knows about.

**HINTHINT:** When you perform a restart, any changes you've made the request headers will be carried over

**HINTHINTHINT:** Think about where you would want to change the Host and URL so you don't end up changing the cache key.

## One Possible Solution

Please try to implement a solution before revealing the possible solution below. This answer is just one possible solution. If you got your app working one way, try sticking with that way and see where problems may come up. This can help you troubleshoot other issues better in the future.

<details><summary></summary>
Because I don't want to have to encode the URL myself, and because Rails is sending back a URL that already has all the variables S3 needs to find our account and the specific photo in that account, I want to just grab the URL from the `Location` header in the 302 that comes back. We can do that with some [good ol' fashioned regex](https://docs.fastly.com/guides/vcl-tutorials/vcl-regular-expression-cheat-sheet).

 Let's start by building a condition in `vcl_fetch` that looks for a `Location` header that points to our S3 bucket:

```perl
if(beresp.http.Location ~ "practice-blog-pix.s3.us-east-2.amazonaws.com(.*)") {
  set req.http.my-s3-url = re.group.1;
  restart;
}
```

You would have to update the domain in the location to match your own S3 bucket.

Notice how we end that code block by calling `restart;`. That will restart the request and run it back through your VCL, starting in `vcl_recv`. We can use a vanity header with the stored URL to send the request to the S3 backend you should have already created. Here's what I have in `vcl_recv`:

```perl
if (req.http.my-s3-url) {
  set req.backend = F_My_S3_bucket;
}
```

Obviously, you would have to update the vanity header and backend names to match what you already have in your own service.

Here, we'll check for the existence of the vanity header we created in `vcl_fetch`. The only time that header should be set is if Heroku is responding with a 302 => S3, so if that header exists, we'll set the S3 backend.

Notice that I'm only setting the backend here. I can set the `Host` and `URL` headers in `vcl_miss` and `vcl_pass`. Can you remember why I wouldn't want to set them in `vcl_recv`? Here's what I have in `vcl_miss` and `vcl_pass`:

```perl
if (req.backend == F_My_S3_bucket) {
  set bereq.http.host = "practice-blog-pix.s3.us-east-2.amazonaws.com";
  set bereq.url = req.http.my-s3-url;
}
```

You would have to update the vanity header, S3 Host, and backend names to match what you already have in your own service.

One problem might come up during this. If you're using [VCL Snippets](https://docs.fastly.com/vcl/vcl-snippets/using-regular-vcl-snippets/) to add this backend, run through your VCL to check the flow of this request. One thing you might notice is that we're accidentally overwriting the backend we set in `vcl_recv`:

```perl
# Snippet set S3 backend : 100
if (req.http.my-s3-url) {
  set req.backend = F_My_S3_bucket;
}
  # default conditions
  set req.backend = F_heroku;
    # end default conditions
```

This is because Snippets are added before we add default conditions to the customer VCL. The solution to this is a bit hacky, but we do this quite commonly with our customers. We need to add conditions to our backends that will never be true, e.g. `if (!req.url)`. That way we'll never overwrite our backend. We will also need to set our Heroku backend by in a Snippet. To ensure that the Heroku backend is set before your S3 backend, look into the `Advanced Options` in your Snippet and set the priority.

If you set everything up correctly, your `vcl_recv` should look like this, but with your backend names:

```perl
# Snippet set Heroku backend : 1
set req.backend = F_heroku;
# Snippet set S3 backend : 100
if (req.http.my-s3-url) {
  set req.backend = F_My_S3_bucket;
}
# default conditions
  # end default conditions
# Request Condition: no default Prio: 10
if( !req.url ) {
  set req.backend = F_heroku;
}
```

Once you have all of that set up, grab a curl from the browser and run it in your terminal. Make sure you add `-I` to see the response headers and `-H "Fastly-Debug: true"` to see the Fastly debug headers. Run the request several times, you should start seeing cache HITs once the object is in cache. Remember! You might have to [purge your service](https://docs.fastly.com/guides/purging/) first to see the changes you made.

</details>

[Return Home](https://github.com/squeemishly/practice_blogger)
