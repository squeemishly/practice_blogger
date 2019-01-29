# Practice Blogger

This app was created to allow customers and new employees to have a tool to test out Fastly configurations. It is not sophisticated. But it does have the primary elements most apps have to allow engineers to test out the tools available to you on Fastly. Enjoy!

# Setup

## Database

I used postgres. Run your standard rails commands to set up your local environment:

1. rake db:create
1. rake db:migrate
1. rake db:seed

## AWS bucket

User profile photos are stored in an AWS bucket. You'll need to set up your own bucket and grab the credentials from it.

I used the Figaro gem to secure my environment variables. To set this up for yourself, run `bundle exec figaro install` in your terminal. Then, set your environment variables in `config/application.yml`. You'll need the following variables:

  * `aws_access_key_id:`
  * `aws_secret_access_key:`

Finally, in `config/storage.yml`, make sure the `amazon` setup is your own. You'll likely need to update your region and your bucket.

## Testing

I used RSPEC for testing. To run the full test suite, just run `rspec` in your terminal. Otherwise, `rails s` and click around!
