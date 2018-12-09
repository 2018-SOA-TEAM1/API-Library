# frozen_string_literal: true

require 'dry/transaction'

module MLBAtBat
  module Service
    # Add project into database and get it
    class SearchGame
      include Dry::Transaction

      step :validate_input
      step :request_game
      step :depresent_game

      private

      def validate_input(input)
        if input[:date].success?
          date = input[:date][:game_date]
          # convert it back to correct format
          date.tr! '/', '_'
          Success(date: date, team_name: input[:team_name])
        else
          Failure(input[:date].errors.values.join('; '))
        end
      end

      def request_game(input)
        result = Gateway::Api.new(MLBAtBat::App.config)
          .search_game(input[:date], input[:team_name])

        result.success? ? Success(result.payload) : Failure('Game not exist')
      rescue StandardError
        Failure('Cannot add projects right now; please try again later')
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
