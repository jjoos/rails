require 'generators/generators_test_helper'
require 'rails/generators/rails/app/app_generator'

class ApiAppGeneratorTest < Rails::Generators::TestCase
  include GeneratorsTestHelper
  tests Rails::Generators::AppGenerator

  arguments [destination_root, '--api']

  def setup
    Rails.application = TestApp::Application
    super

    Kernel::silence_warnings do
      Thor::Base.shell.send(:attr_accessor, :always_force)
      @shell = Thor::Base.shell.new
      @shell.send(:always_force=, true)
    end
  end

  def teardown
    super
    Rails.application = TestApp::Application.instance
  end

  def test_skeleton_is_created
    run_generator

    default_files.each { |path| assert_file path }
    skipped_files.each { |path| assert_no_file path }
  end

  def test_api_modified_files
    run_generator

    assert_file "Gemfile" do |content|
      assert_no_match(/gem 'coffee-rails'/, content)
      assert_no_match(/gem 'jquery-rails'/, content)
      assert_no_match(/gem 'sass-rails'/, content)
    end

    assert_file "config/initializers/wrap_parameters.rb" do |content|
      assert_no_match(/wrap_parameters/, content)
    end
    assert_file "app/controllers/application_controller.rb", /ActionController::API/
  end

  private

  def default_files
    files = %W(
      .gitignore
      Gemfile
      Rakefile
      config.ru
      app/controllers
      app/mailers
      app/models
      config/environments
      config/initializers
      config/locales
      db
      lib
      lib/tasks
      lib/assets
      log
      test/fixtures
      test/controllers
      test/integration
      test/models
    )
    files.concat %w(bin/bundle bin/rails bin/rake)
    files
  end

  def skipped_files
    %w(app/assets
       app/helpers
       app/views
       config/initializers/assets.rb
       config/initializers/cookies_serializer.rb
       config/initializers/session_store.rb
       vendor/assets
       tmp/cache/assets)
  end
end
