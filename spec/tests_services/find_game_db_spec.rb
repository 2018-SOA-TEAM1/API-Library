# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of FindGame service and API gateway' do
  it 'must find game_info with date and teamname which is already in db' do
    # GIVEN a game is in the databasee
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request game with date and team_name
    input = { date: GAME_DATE_API, team_name: SEARCH_TEAM_NAME }
    res = MLBAtBat::Service::FindGame.new.call(input)

    # THEN we should see a game_info
    _(res.success?).must_equal true
    game = res.value!

    _(game.game_pk).must_equal 530_779
    _(game.home_team_name).must_equal 'Baltimore Orioles'
  end
end
