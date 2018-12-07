# frozen_string_literal: true

folders = %w[presentation infrastructure application]
folders.each do |folder|
  require_relative "#{folder}/init.rb"
end
