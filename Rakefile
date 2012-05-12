$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'PullToRefresh'
  
  app.deployment_target = '5.0'
  
  app.files.unshift File.join(app.project_dir, 'vendor/PullToRefresh/pull_refresh_table_view_controller.rb')
  app.frameworks += [
    'QuartzCore',
  ]
end
