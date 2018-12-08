# frozen_string_literal: true

require 'dry/transaction'

module MLBAtBat
  module Service
    # Retrieves first game in db (it should have at least 1 record in db)
    class FindFirstGame
      include Dry::Transaction

      step :find_first_game
      step :depresent_game

      private

      def find_first_game
        result = Gateway::Api.new(MLBAtBat::App.config)
          .find_first_game
        result.success? ? Success(result.payload) : Failure(result.message)
      rescue StandardError
        Failure('Cannot find first game right now; please try again later')
      end

      def depresent_game(wholegame_json)
        Representer::WholeGame.new(OpenStruct.new)
          .from_json(wholegame_json)
          .yield_self { |whole_game| Success(whole_game) }
      rescue StandardError
        Failure('Error in the game -- please try again')
      end
    end
  end
end
