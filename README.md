# Practice Blogger

This app was created to allow customers and new employees to have a tool to test out Fastly configurations. It is not sophisticated. But it does have the primary elements most apps have to allow engineers to test out the tools available to you on Fastly. Enjoy!

[See it live on Heroku](https://sleepy-lake-50116.herokuapp.com/)
[Check it out on Fastly](http://practice-blogger.com)

![Homepage Screenshot](https://github.com/squeemishly/practice_blogger/blob/master/app/assets/images/app_screenshots/practice-blogger-home.png)

# Setup

## Database

I used postgres. Run your standard rails commands to set up your local environment:

1. rake db:create
1. rake db:migrate
1. rake db:seed

## AWS bucket

User profile photos are stored in an AWS bucket. You'll need to set up your own bucket and grab the credentials from it.

### Set up your AWS bucket in the App

I used the Figaro gem to secure my environment variables. To set up your AWS bucket in the app:

1. Run `bundle exec figaro install` in your terminal.
1. Set the `aws_access_key_id:` and `aws_secret_access_key:` environment variables in `config/application.yml`.
1. In `config/storage.yml`, change the region and bucket in your `amazon` setup to match your S3 configuration.

## Heroku

### Deploying

1. Create a heroku login
1. Download the heroku cli
1. In terminal, run `heroku login` and follow instructions
1. In terminal, in the app's directory, run `heroku create`
1. Run `git push heroku master`
1. Run `heroku run rake db:migrate`
1. Run `figaro heroku:set -e production` to set environment variables
1. Run `heroku run rake db:seed` to create some fake seed data
1. Run `heroku open` to see your beautiful new app

### Make an Admin

1. Create an account for yourself in the app. Remember your username.
1. In your terminal, in the app directory, run `heroku pg:psql`.
1. In the heroku postgres database, you can see your account info with `Select username, role from users where username like '<your_username>';`.
1. To update your account to an admin, run `Update users set role = 1 where username like '<your_username>';`.
1. Go back to your app and revel in the administrative glory.

# Testing

I used RSPEC for testing. To run the full test suite, just run `rspec` in your terminal. Otherwise, `rails s` and click around!

# Features
