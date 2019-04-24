# Redirect From Heroku

## Problem Description

There are certain behaviors that trigger redirects from the Rails app to another page in the app. The problem is, that redirect points to the Heroku domain, not your fancy custom domain you have set up on Fastly. This means that when one of these redirects happen, your user starts interacting directly with Heroku and is no longer being routed through Fastly. Booooooo.

Mozilla has [a good description to help understand what's happening in a redirect](https://developer.mozilla.org/en-US/docs/Web/HTTP/Redirections). Essentially, when a redirect is issued, the HTTP status code will usually be a 301 or a 302. There will also be a `Location` header that goes along with the response. This response goes back to the browser, which is smart enough to know it needs to issue another request, this time for the resource in the `Location` header. The browser will update the address bar accordingly.

## Test the Problem

### In the Browser

Visit your app using your fancy purchased domain. You should see the home page load and your fancy domain in the address bar. Neat! In the app setup instructions, you should have created a profile and made yourself an admin. Go ahead and login using the credentials you used to create your profile. When you login, Rails triggers a redirect to the `/articles` path. If you check the address bar, you'll see that the domain has changed to your Heroku address.

### Via curl



## Documentation to Solve the Problem

In our case, the 302 redirect coming back from Heroku has a `Location` header that points directly to Heroku. Because the response runs through Fastly before it is sent back to the client, we have an opportunity to update that `Location` header.

**HINT** When a response comes back from the origin, the first subroutine it will run in is `vcl_fetch`. If you wish to edit the response back to the client, you would want to change the `beresp.` variable. This solution will likely take a small bit of regex to implement. :D

## One Possible Solution

Please try to implement a solution before revealing the possible solution below. This answer is just one possible solution. If you got your app working one way, try sticking with that way and see where problems may come up. This can help you troubleshoot other issues better in the future

<details><summary>Click to See One Possible Solution</summary>
The primary thing we want to do is grab the response being sent back to the browser, and update the `Location` header to point to the domain that runs through Fastly.

Try implementing the following code in `vcl_fetch`:

```perl
if(beresp.http.Location ~ "salty-lake-12345.herokuapp.com(.*)") {
  set beresp.http.Location = re.group.1;
}
```

Here's what we're doing: We're checking to see if the backend response has a `Location` header that points to our Heroku app. That bit at the end, `(.*)`, will grab everything that comes after the domain using some [good ol' fashioned regex](https://docs.fastly.com/guides/vcl-tutorials/vcl-regular-expression-cheat-sheet). That value is the path that we're interested in. By surrounding it in parentheses, we're making a group out of whatever that URL happens to be. We can reference that value by calling `re.group.1`, which stands for `regex group 1`. If you want to be thorough, you can add in your protocol, `http://`, and your domain, `www.example.com`; however, if the browser receives a redirect that only contains the path, it assumes that it needs to keep using the same domain it was already working with, just go to a different path.

Clearly, you will need to change this code block so `salty-lake-12345.herokuapp.com` is replaced with your domain on Heroku.

</details>

## Super Secret Awesome Knowledge

<details><summary>Wanna Know How to Fix This Using Rails?</summary>
Rails has a really cool feature where if you send in an `x-forwarded-host` header, it will respect that header when it creates redirects. So if I pass my request to Rails, and it contains `x-forwarded-host: www.example.com`, when Rails issues a redirect, instead of pointing to the Heroku app, it will point to `www.example.com`.

To implement this solution, we can edit the code block we created when we [updated our host](update_the_host.md). Try changing the snippets for `vcl_miss` and `vcl_pass` to the following:

```perl
if (req.backend == F_heroku) {
  set bereq.http.host = "salty-lake-12345.herokuapp.com";
  set bereq.http.x-forwarded-host = "www.example.com";
}
```

You will need to change this code block so `salty-lake-12345.herokuapp.com` points to your URL on Heroku and `www.example.com` is your purchased domain.
</details>

[Return Home](https://github.com/squeemishly/practice_blogger)
