# frozen_string_literal: true

# This is used as part of a take task, and will be run within a console.
# rubocop:disable Rails/Output

class PurposeConfig
  attr_reader :name, :options, :store, :api
  class_attribute :default_printer, :default_presenter, :default_creator, :default_state_changer

  self.default_state_changer = 'StateChangers::DefaultStateChanger'

  def self.load(name, options, store, api, submission_templates)
    case options.fetch(:asset_type)
    when 'plate' then PurposeConfig::Plate.new(name, options, store, api, submission_templates)
    when 'tube' then PurposeConfig::Tube.new(name, options, store, api, submission_templates)
    else raise "Unknown purpose type #{options.fetch(:asset_type)} for #{name}"
    end
  end

  def initialize(name, options, store, api, submission_templates)
    @name = name
    @options = options
    @submission = options.delete(:submission)
    @store = store
    @api = api
    @submission_templates = submission_templates
  end

  def submission_options
    return {} if @submission.nil?
    {
      request_options: @submission.fetch('request_options', {}),
      template_uuid: @submission_templates[@submission.fetch('template_name')]
    }
  end

  def parents
    @options.fetch(:parents, []).map { |parent_name| store.fetch(parent_name).uuid }
  end

  def config
    {
      name: name,
      creator_class: default_creator,
      presenter_class: default_presenter,
      state_changer_class: default_state_changer,
      default_printer_type: default_printer,
      submission: submission_options
    }.merge(@options)
  end

  def uuid
    store.fetch(name).uuid
  end

  class Tube < PurposeConfig
    self.default_printer = :tube
    self.default_presenter = 'Presenters::SimpleTubePresenter'
    self.default_creator = 'LabwareCreators::TubeFromTube'

    def register!
      puts "Creating #{name}"
      api.tube_purpose.create!(
        name: name,
        target_type: options.fetch(:target),
        type: options.fetch(:type)
      )
    end
  end

  class Plate < PurposeConfig
    self.default_printer = :plate_a
    self.default_presenter = 'Presenters::StandardPresenter'
    self.default_creator = 'LabwareCreators::StampedPlate'

    def register!
      puts "Creating #{name}"
      api.plate_purpose.create!(
        name: name,
        stock_plate: config.fetch(:stock_plate, false),
        cherrypickable_target: config.fetch(:cherrypickable_target, false),
        input_plate: config.fetch(:input_plate, false),
        size: config.fetch(:size, 96)
      )
    end
  end
end
# rubocop:enable Rails/Output
