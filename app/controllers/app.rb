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
        # Get cookie viewer's previously seen projects
        session[:watching] ||= []

        # get games from db
        games = Repository::For.klass(Entity::LiveGame).all

        games.none? && flash.now[:notice] = 'Search for a game to get started'

        # condition: first time open browser to get to homepage
        # and have game in db
        begin
          if games.any? && $whole_game.nil?
            first_game = Repository::For.klass(Entity::LiveGame).first
            date = first_game.date.to_s
            date = (date[4...6] + '/' + date[6...8] + '/' + date[0...4])
            team_name = first_game.home_team_name
            game_pk = MLB::ScheduleMapper.new.get_gamepk(date, team_name)
            $whole_game = Mapper::WholeGame.new.get_whole_game(game_pk)
          end
          if valid_date?(routing.cookies['date'])
            date = routing.cookies['date']
            team_name = MLB::ScheduleMapper.new.get_team_name(date)
          end
        rescue StandardError
          flash[:error] = 'Having trouble getting game from db'
          routing.redirect '/'
        end

        # show particular game information in homepage
        viewable_games = Views::GamesList.new(games)
        games.any? && viewable_whole_game = Views::WholeGame.new($whole_game)
        view 'home', locals: { games: viewable_games, team_name: team_name,
                               whole_game: viewable_whole_game }
      end

      routing.on 'game_info' do
        routing.is do
          # GET /game_info/
          routing.post do
            date = routing.params['game_date']
            team_name = routing.params['team_name']

            # get schedule from api
            begin
              game_info = MLB::ScheduleMapper.new.get_schedule(1, date)
            rescue StandardError
              flash[:error] = 'Can not get schedule from ScheduleMapper 
                (through api).'
              routing.redirect '/'
            end

            # get game_pk from mapper
            begin
              game_pk = MLB::ScheduleMapper.new.get_gamepk(date, team_name)
              if game_pk.nil?
                flash[:error] = 'Can not find game in
                  given search date and team name.'
                routing.redirect '/'
              end
            rescue StandardError
              flash[:error] = 'Can not get game_pk from ScheduleMapper mapper
                (through api).'
              routing.redirect '/'
            end

            # build whole game
            begin
              $whole_game = Mapper::WholeGame.new.build_entity(game_pk)
            rescue StandardError
              flash[:error] = 'Can not get wholegame from WholeGame mapper.'
              routing.redirect '/'
            end

            # add schedule (and game) to database
            begin
              Repository::For.entity(game_info).create(game_info, team_name)
            rescue StandardError
              flash[:error] = 'Having trouble adding schedule/game into db.' 
              routing.redirect '/'
            end

            date = date.split('/').join('_')
            team_name = team_name.split(' ').join('_')
            routing.redirect "game_info/#{date}/#{team_name}"
          end
        end

        routing.on String, String do |date, team_name|
          # GET /game_info/date/team_name
          routing.get do
            date = date.split('_').join('/')
            team_name = team_name.split('_').join(' ')

            # find particular game from db
            begin
              game_info = Repository::For.klass(Entity::LiveGame)
                .find(date, team_name)
            rescue StandardError
              flash[:error] = 'Can not get game from db using date
                and team_name.'
              routing.redirect '/'
            end

            viewable_game_info = Views::GameInfo.new(game_info)
            # show game information which is from db
            view 'game_info', locals: { game_info: viewable_game_info }
          end
        end
      end
    end

    def valid_date?(str, format = '%m/%d/%Y')
      Date.strptime(str, format)
    rescue StandardError
      false
    end
  end
end
