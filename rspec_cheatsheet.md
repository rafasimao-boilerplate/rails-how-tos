# Cheatsheet of rspec tests usual questions

#### How to add a request header to a controller request

You may add a request header by setting it diractly to the `request` object, for instance:
```
...
  request.env['some_useful_header'] = true
  post :create, params: { email: email }
...
```
