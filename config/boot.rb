require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

APP_ROOT = File.expand_path(File.dirname(__FILE__) + "/../")

# include hash helpers:
#  in general I don't like sending 'live' activerecord objects to views, so
#  I have created these hash generators to create simple hashes for use in views
Dir.glob(APP_ROOT + '/lib/nci/views/*.rb') {|lib| require lib }

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
