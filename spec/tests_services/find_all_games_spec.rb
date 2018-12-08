# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of FindAllGames service and API gateway' do
  it 'must find all game_info in db' do
    # GIVEN a game is in the databasee
    MLBAtBat::Gateway::Api.new(MLBAtBat::App.config)
      .search_game(GAME_DATE_API, SEARCH_TEAM_NAME)

    # WHEN we request all games
    res = MLBAtBat::Service::FindAllGames.new.call

    # THEN we should see a list of games (only 1 game in it)
    _(res.success?).must_equal true
    data = res.value!

    _(data.livegames.count).must_be :>=, 1
    _(data.livegames.first.game_pk).must_equal 530_779
  end
end
