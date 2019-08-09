# How to receive emails in your Rails App

To send and receive emails, you will need a mail server. For that purpose you might want to use a something like sendgrid to intermediate your emails.

In this tutorial we will use sendgrid. So here are the steps you will need to do:
- Setup an email domain
- Setup a sendgrid account 
- Authenticate your email domain on sendgrid
- Create an Inbound Parse at sendgrid
- Setup Griddler at your project
- Run a localtunnel or ngrok to expose your local to the world

### Setup a Inbound Parse

For this you will need to have an authenticated domain to use for this purpose.
Just add the domain and the url of the endpoint which will receive your request.[Link](https://sendgrid.com/docs/for-developers/parsing-email/setting-up-the-inbound-parse-webhook/).

Setup the domain as a MX record pointing to `mx.sendgrid.net`(Case youre using sendgrid).

### Setup Griddler

Just add the griddler gem and the griddler adapter gem:
```
gem 'griddler'
gem 'griddler-sendgrid'
```

Run a `bundle install` then add the griddler endpoint to the routes file, one way of doing that is just adding a `mount_griddler` to your file.

Then create an EmailProcessor to proceess the email that will be received in the griddler endpoint created:
```ruby
class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    # your code will come here to process the informations from the email
  end
end
```

### Setup Localtunnel

- Install the localtunnel in your machine: `npm install -g localtunnel`

- Run your server: `rails s -b 0.0.0.0`, run it with the `-b 0.0.0.0` to expose it to the network.

- Run the localtunnel exposing the port `lt --port 3000`

- Use the generated url to access your local endpoint `your url is: https://cgoyfetijd.localtunnel.me`
