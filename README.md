# Install

1. clone the repository
2. install the gem dependencies with bundler for your environment (development, production, staging, etc)

```shell
RAILS_ENV=development bundle install
```

3. copy config/database.yml.sample to config/database.yml and edit to taste
4. copy config/initializers/secret_token.rb.sample config/initializers/secret_token.rb and edit (random string)
5. copy config/initializers/attr_encrypted.rb.sample config/initializers/attr_encrypted.rb.sample and edit with an encryption password (random string)

6. set up the database for your environment (development, production, staging, etc)

```shell
RAILS_ENV=development rake db:setup
```

7. edit your mail settings in the appropriate environment file

emacs config/environments/development.rb

8. boot up the app with your server of choice (unicorn, passenger, etc) or in development with:

```
RAILS_ENV=development bundle exec rails server
```

9. register using the website itself

10. enter rails console

```
RAILS_ENV=development bundle exec rails console
```

11. in rails console, add the :admin role to your user

```ruby
my_user = User.last
my_user.roles = [:admin]
my_user.save
```

12. visit the admin area at /admin
