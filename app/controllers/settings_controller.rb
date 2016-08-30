require 'yaml'

class SettingsController < ApplicationController
  def index
    @settings = YAML.load_file(File.join(Rails.root, "config", "setup_questions.yml"))
  end

  def change
    updated_settings = params[:settings]
    p updated_settings
    updated_settings.each do |setting, value|
      puts "setting: #{setting}"
      puts "value: #{value}"
      puts "#{setting.to_sym}"
      puts "***"
      current_account.settings(setting.to_sym).val = value
      current_account.save!
      puts "***"
    end
    redirect_to settings_path, notice: "Settings Updated Successfully!"
  end
end
