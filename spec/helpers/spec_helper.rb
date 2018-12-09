# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'pry' # for debugging

require_relative '../../init.rb'

SPORT_ID = 1
WRONG_PK_ID = '600000'
GAME_DATE = '07/10/2018'
SEARCH_TEAM_NAME = 'Baltimore Orioles'

GAME_DATE_API = '07_10_2018'

CORRECT = YAML.safe_load(File.read('spec/fixtures/mlb_results.yml'))
RESPONSE = YAML.load(File.read('spec/fixtures/mlb_response.yml'))

# Helper methods
def homepage
  MLBAtBat::App.config.APP_HOST
end
