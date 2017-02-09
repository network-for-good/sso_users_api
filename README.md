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
  SsoUsersApi::Token.new.create
````

## Using the Users API
Before you can use the Users api, you must set the access token on the Base class so it can be used to set the authorization header. Add the following line to an initializer file and set the token in API_KEYS (do not include it in the repository)

````
  SsoUsersApi::Base.access_token = [access_token created from above]
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

## Using the User Manager
This gem provides a convenience method for using the api which performs the interactions with the api for you.

Before using the manager, you should create a migration to add an sso_id field to whatever user class will be managed using this library.  For example, if the user class was Admins, the migration would be the following:

````
  def change
    add_column :admins, :sso_id, :string, foreign_key: false
  end

````

To use the Manager, simply pass in the admin/user you want to Add/Update and the manager will make the appropriate calls

````
SsoUsersApi::Manager.new(user).call
````

The Manager will create a new user, or update an existing user, depending on the value of a sso_id field. If this attribute does not exist on the user object, it will always use the create (which works like an update on the api). If there is an sso_id attribute, and it is blank, it will perform the create, then update the sso_id field. If the sso_id field has a value, it will use the update function.

## Using the User Manager Job
The UserManagerJob is an activejob class that can be used where the interaction with the identity server can happen asynchroneously.

To use the job, simple call perform_later on the class, passing in the id of the user and the class name of the user.

````
user = Admin.find(132)
SsoUsersApi::ManagerJob.perform_later(132, user.class.name)
````

If the interaction with the sso api fails (TimeOut, HTTPConnection, 500, etc), the job will put itself back on the queue after waiting 5 seconds.

## Console
To start a console, bundle, then cd into spec/dummy. Runs `rails c` fro there