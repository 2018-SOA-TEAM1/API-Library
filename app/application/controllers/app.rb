# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require 'pry'
require 'date'

module MLBAtBat
  # Web App
  class App < Roda
    # plugins
    plugin :halt
    plugin :flash
    plugin :all_verbs
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', js: 'datepicker.js'

    use Rack::MethodOverride

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        # get games from db
        result = Service::FindAllGames.new.call
        result.failure? && flash[:error] = result.failure

        games = result.value!.livegames
        games.none? && flash.now[:notice] = 'Search for a game to get started'

        if games.any? && $whole_game.nil?
          result = Service::FindFirstGame.new.call
          $whole_game = result.value!
        end

        # show particular game information in homepage
        viewable_games = Views::GamesList.new(games)
        games.any? && viewable_whole_game = Views::WholeGame.new($whole_game)

        view 'home', locals: { games: viewable_games,
                               whole_game: viewable_whole_game }
      end

      routing.on 'game_info' do
        routing.is do
          # GET /game_info/
          routing.post do
            date = routing.params['game_date']
            team_name = routing.params['team_name']
            date_request = Forms::DateRequest.call(routing.params)

            input = { date: date_request, team_name: team_name }
            search_game = Service::SearchGame.new.call(input)
            if search_game.failure?
              flash[:error] = search_game.failure
              routing.redirect '/'
            end
            $whole_game = search_game.value!

            date = date.split('/').join('_')
            team_name = team_name.split(' ').join('_')
            routing.redirect "game_info/#{date}/#{team_name}"
          end
        end

        routing.on String, String do |date, team_name|
          # GET /game_info/date/team_name
          routing.get do
            # find particular game from db
            input = { date: date, team_name: team_name }
            find_game = Service::FindGame.new.call(input)
            if find_game.failure?
              flash[:error] = find_game.failure
              routing.redirect '/'
            end
            game_info = find_game.value!

            viewable_game_info = Views::GameInfo.new(game_info)
            # show game information which is from db
            view 'game_info', locals: { game_info: viewable_game_info }
          end
        end
      end
    end
  end
end
