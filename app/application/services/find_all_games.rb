# frozen_string_literal: true

require 'dry/transaction'

module MLBAtBat
  module Service
    # Retrieves array of all listed game_info entities
    class FindAllGames
      include Dry::Transaction

      step :find_all_games
      step :depresent_games

      private

      def find_all_games
        result = Gateway::Api.new(MLBAtBat::App.config)
          .find_all_games
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot find first game right now; please try again later')
      end

      def depresent_games(games_json)
        Representer::LivegamesList.new(OpenStruct.new)
          .from_json(games_json)
          .yield_self { |games| Success(games) }
      rescue StandardError
        Failure('Error in the game -- please try again')
      end
    end
  end
end
