# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Unit test of MLBAtBat API gateway' do
  it 'must report alive status' do
    alive = MLBAtBat::Gateway::Api.new(MLBAtBat::App.config).alive?
    _(alive).must_equal true
  end

  it 'must be able to search a game from MLB API' do
    res = MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    _(res.success?).must_equal true
    data = res.parse

    _(data.keys.count).must_be :>=, 11
    _(data['innings'].count).must_equal 9
    _(data['gcms'].count).must_equal 3
  end

  it 'must find game_info with date and teamname which is already in db' do
    # GIVEN a game is in the database
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request a game with date and team_name
    res = MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .find_game_db(GAME_DATE_API, SEARCH_TEAM_NAME)

    # THEN we should see a game_info
    _(res.success?).must_equal true
    data = res.parse

    _(data.keys).must_include 'game_pk'
    _(data['game_pk']).must_equal 530_779
    _(data['home_team_name']).must_equal 'Baltimore Orioles'
  end

  it 'must find first game in db' do
    # GIVEN a game is in the database
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request first game
    res = MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .find_first_game

    # THEN we should see a game
    _(res.success?).must_equal true
    data = res.parse
    _(data.keys.count).must_be :>=, 11
    _(data['innings'].count).must_equal 9
    _(data['gcms'].count).must_equal 3
  end

  it 'must find all games in db' do
    # GIVEN a game is in the database
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request all games
    res = MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .find_all_games

    # THEN we should see a list of games
    _(res.success?).must_equal true
    data = res.parse

    _(data['livegames'].count).must_be :>=, 1
    _(data['livegames'].first['game_pk']).must_equal 530_779
  end
end
