# frozen_string_literal: true

require_relative '../helpers/spec_helper.rb'

describe 'Integration test of SearchGame service and API gateway' do
  it 'must add a legitimate game' do
    # WHEN we request to add a game
    # to pass form, we need to convert '-' to '/'
    form_date_input = GAME_DATE_API.tr '-', '/'
    date_request = MLBAtBat::Forms::DateRequest.call(game_date: form_date_input)
    input = { date: date_request, team_name: SEARCH_TEAM_NAME }
    res = MLBAtBat::Service::SearchGame.new.call(input)

    # THEN we should see a single game
    _(res.success?).must_equal true
    game = res.value!

    _(game.game_pk).must_equal 530_779
    _(game.innings.count).must_equal 10 # first inning is null
  end
end
