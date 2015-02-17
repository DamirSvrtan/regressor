require 'regression_model'
class SpecRegressionGenerator < Rails::Generators::Base

  def all_models
    # must eager load all the classes...
    Dir.glob("#{Rails.root}/app/models/**/*.rb") do |model_path|
      begin
        require model_path
      rescue
        # ignore
      end
    end
    # simply return them
    ActiveRecord::Base.send(:subclasses)
  end


  def create_regression_files
    all_models.map(&:name).reject { |x| ["ActiveType::Record", "ActiveType::Object", "HABTM_Users", "HABTM_Roles"].include? x }.each do |model|
      @model = RegressionModel.new(model)
      create_file "spec/models/regression/#{model.tableize.gsub("/", "_").singularize}_spec.rb", ERB.new(File.new(File.expand_path('templates/spec_regression_template.rb.erb', File.dirname(__FILE__))).read).result(binding)
    end
  end

end