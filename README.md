# Practice Blogger

This app was created to allow customers and new employees to have a tool to test out Fastly configurations. It is not sophisticated. But it does have the primary elements most apps have to allow engineers to test out the tools available to you on Fastly. Enjoy!

[See it live on Heroku](https://sleepy-lake-50116.herokuapp.com/) or [check it out running through Fastly](http://practice-blogger.com).

![Homepage Screenshot](https://github.com/squeemishly/practice_blogger/blob/master/app/assets/images/app_screenshots/practice-blogger-home.png)

## Database

I used postgres. The basic schema is this:

![Schema Screenshot](https://github.com/squeemishly/practice_blogger/blob/master/app/assets/images/app_screenshots/schema.png)

### Install Postgres

Run `psql` in your terminal. If you see a `command not found` error, you need to install Postgres. I recommend using [Homebrew](https://brew.sh/) bun running this command: `brew install postgresql`.

### Local Environment Setup

You only need to do this if you want to see the app on your local server. To do so, run your standard rails commands to set up your local environment:

1. rake db:create
1. rake db:migrate
1. rake db:seed

## Setup

The basic flow of a request through Fastly will be this:

1. A user makes a request to a domain you have purchased, e.g. `www.example.com`
1. There is a DNS lookup on that domain. Your DNS should point to Fastly.
1. Fastly receives the request. If the object is in cache, it will respond with that object. If it isn't...
1. Fastly will go to your origin to retrieve that object.
1. Fastly receives the object from your origin.
1. Fastly caches that object.
1. Fastly responds to the client with the object.

For more on how Fastly works, [check our docs](https://docs.fastly.com/guides/basic-setup/getting-started-with-fastly)!

The steps described below will outline how to setup Heroku to host this app and be your origin. Once the app is up and running through Fastly, you're free to test out how various features impact requests to this magnificent app!

### Ruby

This app uses Ruby version 2.5.0. If you don't have this installed on your machine, you'll need to install it. To do so, start by installing the Ruby Version Manager:

1. Run `\curl -sSL https://get.rvm.io | bash` in your terminal.
1. Run `rvm install 2.5.0` in your terminal.
1. Run `bundle` to set up your gems.

If you see an error similar to `Your Ruby version is 2.3.7, but your Gemfile specified 2.5.0`, run `rvm use 2.5.0` to force your machine to use the correct version of Ruby.

### AWS bucket

User profile photos are stored in an AWS bucket. So before we can host the app on Heroku, you'll need to [set up your own bucket](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html) and [grab the credentials from your account](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/). Once your bucket is created, you'll need to tell the app where this bucket is.

#### Set up your AWS bucket in the App

I used the [Figaro gem](https://github.com/laserlemon/figaro) to secure my environment variables. To set up your AWS bucket in the app:

1. Run `bundle exec figaro install` in your terminal.
1. Set the `aws_access_key_id:` and `aws_secret_access_key:` environment variables in `config/application.yml`.
1. In `config/storage.yml`, change the region and bucket in your `amazon` setup to match your S3 configuration.

### Heroku

#### Deploying

1. Create a [heroku login](https://id.heroku.com/login).
1. Download and install the [heroku cli](https://devcenter.heroku.com/articles/heroku-cli#download-and-install).
1. In terminal, run `heroku login` and follow instructions.
1. CD into the app's directory.
1. Run `heroku create` to add a heroku endpoint to your git repo.
1. Run `git push heroku master` to push the app to the heroku endpoint.
1. Run `heroku run rake db:migrate` to create the database schema for the app.
1. Run `figaro heroku:set -e production` to set environment variables.
1. Run `heroku run rake db:seed` to create some fake seed data.
1. Run `heroku open` to see your beautiful new app.

#### Make an Admin

1. Open the app in your browser. You can use `heroku open` from the app directory in your terminal.
1. Create an account for yourself in the app. Remember your username.
1. In app directory in terminal, run `heroku pg:psql`.
1. In the heroku postgres database, you can see your account info with `Select username, role from users where username like '<your_username>';`.
1. To update your account to an admin, run `Update users set role = 1 where username like '<your_username>';`.
1. Go back to your app and revel in the administrative glory.

### Purchase your Domain

To get a service up and running on Fastly, you'll need a domain that you can point the internet to. The domain Heroku gives you, e.g. `salty-lake-12345.herokuapp.com`, is where you're going to point Fastly. You can use any domain registrar.

### Fastly

1. Create an account.
1. Create a service on that account.
1. In the `Configure` tab, under the `Domains` section, click on `Create Your First Domain`.
1. Add the domain you purchased from the domain registrar.
1. In the `Configure` tab, under the `Origins` section, click on `Create Your First Host`.
1. Give your origin a name, e.g. `heroku_app`.
1. In the Address field, enter the domain Heroku gave you.
1. Let's skip setting up TLS for now. Under `Enable TLS`, select the `No` radio button.
1. Click on `Create` at the bottom of the page.
1. Click the `Activate` button at the top of the screen.

**NOTE:** In a request to an origin server, Fastly will pass along the Host domain from the request. So if you bought `www.example.com` and you run that through Fastly, we will send that to the origin to find the object we're looking for. Unfortunately, Heroku doesn't know anything about `www.example.com`, so we'll get back a generic "This content has not been created yet" message from Heroku. Later, in the `Fixing the Problems` section, we'll look at how to solve this problem by overriding the Host header.

### Point your DNS

Now that we have Fastly set up and Fastly knows where Heroku is, we need to make sure the rest of the internet knows to go to Fastly to request our application. Go back to your domain registrar and manage your DNS for your domain.

If you used an apex domain, e.g. `example.com`, you will need to add A records to your DNS that point to Fastly. Please contact support at support@fastly.com to receive those IPs.

If you used a subdomain, e.g. `www.example.com`, you can add a CNAME to your DNS to point to Fastly:

```
nonssl.global.fastly.net
```

### Check it out

If you set everything up correctly, you should be able to visit the domain you purchased from your domain registrar and see a Heroku message.

But... There's a series of problems. The following section will identify the problems and guide you through fixing them. I recommend reading the section on the problem and attempting to figure out a solution for yourself. If you get stuck, use the tutorial to help you set up your service.

## Fixing the Problems

Much of what we are going to do is going to require some understanding of VCL. I recommend reading [this blog post](https://www.integralist.co.uk/posts/fastly-varnish/) one of our customers wrote several years ago. Some aspects of VCL have changed, but does a great job of summarizing VCL flow. As a copy/paste from that post with only a little editing, here's a summary of the subroutines in VCL:

```
vcl_recv: request is received and can be inspected/modified.
vcl_hash: generate a hash key from host/path and lookup key in cache.
vcl_hit: hash key was found in the cache.
vcl_miss: hash key was not found in the cache.
vcl_pass: content should be fetched from origin, regardless of if it exists in cache or not, and response will not be cached.
vcl_fetch: content has been fetched, we can now inspect/modify it before caching (or not) the object.
vcl_deliver: content has been cached (or not, if we had used return(pass)) and ready to be delivered to the user.
```

Now, onto the problems:

1. [Update the Host header so Heroku can find your app](/readmes/update_the_host.md)
1. [Redirect from Heroku](/readmes/heroku_redirect.md)
1. [Redirect from S3](/readmes/s3_redirect.md)
1. [Heroku Timeouts](/readmes/heroku_timeouts.md)

## Next Steps

Now that you have everything up and running through Fastly, it's time to start looking at how Fastly caches your objects. For example, [how long should Fastly cache your objects?](https://docs.fastly.com/guides/tutorials/cache-control-tutorial). We might want images cached for a week and HTML files cached for a day. Depends on your needs.

Notice that approximately _none_ of your HTML files are caching currently. This is because our app is sending back a `set-cookie` header. Because cookies generally contain data related to a specific user, e.g. session information, we don't want to cache objects that use this cookie. But... we're not always using that cookie. See if you can figure out when you should strip `set-cookies` from the response so Fastly will cache the object.

One fun project is controlling the different views a user can see. For example, when you visit an article as a visitor, you don't have an `Add a Comment` button, but if you visit as a logged in user, you do. We need to cache different objects depending on the session state. I recommend looking into the [Vary header](https://www.fastly.com/blog/best-practices-using-vary-header) to see if this could provide a potential solution.

Fastly doesn't keep logs of customer requests. This can make identifying and troubleshooting issues pretty hard. We recommend all of our customers set up [remote log streaming](https://docs.fastly.com/guides/streaming-logs/setting-up-remote-log-streaming) so we can see what's actually going on with their service.
