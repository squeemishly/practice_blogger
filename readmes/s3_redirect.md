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

**HINTHINT:** Think about where you would want to change the Host and URL so you don't end up changing the cache key.

## One Possible Solution

Please try to implement a solution before revealing the possible solution below. This answer is just one possible solution. If you got your app working one way, try sticking with that way and see where problems may come up. This can help you troubleshoot other issues better in the future.

<details><summary></summary>
</details>

## Super Secret Awesome Knowledge

<details><summary></summary>
</details>

[Return Home](https://github.com/squeemishly/practice_blogger)
