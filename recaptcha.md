# Adding Recaptcha to your rails app

Thanks to Google we have a great recaptcha tecnology to use in any application - [link](https://developers.google.com/recaptcha/intro).

There are mainly three types of recaptcha:
1.v3: No user input is used. Just returns a score and you must use it to decide how to deal with it.
2.v2-checkbox: Adds a checkbox for the user to check and may query other inputs.
3.v3-invisible: Just shows a tag in the corner of your site and query inputs if needed.

Mainly all recaptchas works the same way: you add a recaptcha to a page, before sending the post to your api you must configure it to send a request with your `SITE_KEY` for the google apis to fetch the token and afterwards it will send a `'g-recaptcha-response'` argument in your post so that in your api you can use your `SECRET_KEY` to make another request to google and verify the recaptcha token you received and therefore discover if the request was from a human.

To add recaptcha to your app, you may use the [recaptcha gem](https://github.com/ambethia/recaptcha).

### With Rack::Attack

Rack attack is used to throttle requests its main functionality is return an error when a request is throttled.
[more info..](https://github.com/kickstarter/rack-attack#getting-started)

But there is a integration of rack-attack with recaptcha, the [gem rack-attack-recaptcha](https://github.com/rauchy/rack-attack-recaptcha)
You may use it to throw a recaptcha to throttled requests.

it uses the `verify_recaptcha` and `recaptcha_tags` from the recaptcha gem to integrate, but it will only show the recaptcha tags if the user is being throttled.
