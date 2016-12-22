# SsoUsersApi

## Obtaining a Token
To obtain a token, you will use the SsoUsersApi::Token class. Before requesting the token, you must set the username and password as class values on the class

````
  SsoUsersApi::Token.username [username]
  SsoUsersApi::Token.password [password]
````

If it is likely that you will have to obtain a token repeatedly, you may want to set up an initializer to set these values. Keep in mind that since these are class variables, if your class is reloaded (as it may be in development), these values will be lost and will need to be reset.

To request the token, after setting the username and password. Use:

````
  SsoUsersApi::Token.create
````

## Using the Users API
Before you can use the Users api, you must set the access token on the Base class so it can be used to set the authorization header

````
  SsoUsersApi::Base.access_token [access_token created from above]
````

### Creating a new user

````
  SsoUsersApi::User.new(username: "hoenth@gmail.com", first_name: "Ben", last_name: "Hoen", claims: [ { type: "nfg_account", value: "2087252" } ]).create
````

### Finding a user

````
  SsoUsersApi::User.find "6e4de28f-0044-4c37-9f14-29b48ff66d40"
````

### Updating a user

````
  SsoUsersApi::User.new(id: "6e4de28f-0044-4c37-9f14-29b48ff66d40", username: "hoenth@gmail.com", first_name: "Tom", last_name: "Hoen", claims: [ { type: "nfg_account", value: "2087252" } ]).update
````

## Console
To start a console, bundle, then cd into spec/dummy. Runs `rails c` fro there