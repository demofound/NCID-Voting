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
example:

emacs config/environments/development.rb

8. 
