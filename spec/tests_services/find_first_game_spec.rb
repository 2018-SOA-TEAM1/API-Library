# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of FindFirstGame service and API gateway' do
  it 'must find first game in db' do
    # GIVEN a game is in the databasee
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request first game
    res = MLBAtBat::Service::FindFirstGame.new.call

    # THEN we should see a game
    _(res.success?).must_equal true
    game = res.value!

    _(game.game_pk).must_equal 530_779
    _(game.innings.count).must_equal 9
  end
end
