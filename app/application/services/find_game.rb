# frozen_string_literal: true

require 'dry/transaction'

module MLBAtBat
  module Service
    # Find game with team_name and date in db
    class FindGame
      include Dry::Transaction

      step :find_game
      step :depresent_game

      private

      def find_game(input)
        result = Gateway::Api.new(MLBAtBat::App.config)
          .find_game_db(input[:date], input[:team_name])
        result.success? ? Success(result.payload) : Failure('Fail to show game')
      rescue StandardError
        Failure('Cannot find game right now; please try again later')
      end

      def depresent_game(livegame_json)
        Representer::LiveGame.new(OpenStruct.new)
          .from_json(livegame_json)
          .yield_self { |game_info| Success(game_info) }
      rescue StandardError
        Failure('Error in the game -- please try again')
      end
    end
  end
end
