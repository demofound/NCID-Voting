# Install

*  clone the repository
*  install the gem dependencies with bundler for your environment (development, production, staging, etc)

```shell
RAILS_ENV=development bundle install
```

*  copy config/database.yml.sample to config/database.yml and edit to taste
*  copy config/initializers/secret_token.rb.sample config/initializers/secret_token.rb and edit (random string)
*  copy config/initializers/attr_encrypted.rb.sample config/initializers/attr_encrypted.rb.sample and edit with an encryption password (random string)

*  set up the database for your environment (development, production, staging, etc)

```shell
RAILS_ENV=development rake db:setup
```

*  edit your mail settings in the appropriate environment file

```shell
emacs config/environments/development.rb
```

*  boot up the app with your server of choice (unicorn, passenger, etc) or in development with:

```shell
RAILS_ENV=development bundle exec rails server
```

*  register using the website itself

*   enter rails console

```shell
RAILS_ENV=development bundle exec rails console
```

*  in rails console, add the :admin role to your user

```ruby
my_user = User.last
my_user.roles = [:admin]
my_user.save
```

*  visit the admin area at /admin
