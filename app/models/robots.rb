#This file is part of Illumina-B Pipeline is distributed under the terms of GNU General Public License version 3 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2013,2014,2015 Genome Research Ltd.
module Robots
  class Robot
    include Forms::Form

    class Bed
      include Forms::Form

      class BedError < StandardError; end
      # Our robot has beds/rack-spaces
      attr_reader :plate, :error_message

      class_inheritable_reader :attributes
      write_inheritable_attribute :attributes, [:api, :user_uuid, :purpose, :states, :label, :parent, :target_state, :robot]

      def has_transition?
        @target_state.present?
      end

      def transition
        return if target_state.nil? || plate.nil? # We have nothing to do
        StateChangers.lookup_for(plate.plate_purpose.uuid).new(api, plate.uuid, user_uuid).move_to!(target_state,"Robot #{robot.name} started")
      end

      def error(message)
        @error_message ||= ""
        @error_message << message << " "
        false
      end
      private :error


      def valid?
        case
        when plate.nil? # The bed is empty or untested
          return @barcode.nil? || error("Could not find a plate with the barcode #{@barcode}.")
        when plate.plate_purpose.uuid != Settings.purpose_uuids[purpose]
          error("Plate #{plate.barcode.prefix}#{plate.barcode.number} is a #{plate.plate_purpose.name} not a #{purpose} plate.")
        when !states.include?(plate.state) # The plate is in the wrong state
          error("Plate #{plate.barcode.prefix}#{plate.barcode.number} is #{plate.state} when it should be #{states.join(', ')}.")
        else
          true
        end
      end

      def load(barcode)
        @barcode = barcode
        begin
          @plate = api.search.find(Settings.searches['Find assets by barcode']).first(:barcode => barcode) unless barcode.nil?
        rescue Sequencescape::Api::ResourceNotFound
          @plate = nil
        end
      end

      def parent_plate
        return nil if plate.nil?
        begin
          api.search.find(Settings.searches['Find source assets by destination asset barcode']).first(:barcode => plate.barcode.ean13)
        rescue Sequencescape::Api::ResourceNotFound
          error("Plate #{plate.barcode.prefix}#{plate.barcode.number} doesn't seem to have a parent, and yet one was expected.")
          nil
        end
      end

      def formatted_message
        "#{label} - #{error_message}"
      end

    end

    class InvalidBed
      def initialize(barcode)
        @barcode = barcode
      end
      def load(_)
      end
      def formatted_message
        match = /[0-9]{12,13}/.match(@barcode)
        match ? "Bed with barcode #{@barcode} is not expected to contain a tracked plate." :
                "#{@barcode} does not appear to be a valid bed barcode."
      end
      def valid?
        false
      end
    end

    def self.find(options)
      robot_settings = Settings.robots[options[:location]]
      raise ActionController::RoutingError.new("Location #{options[:location]} Not Found") if robot_settings.nil?
      robot_settings = robot_settings[options[:id]]
      raise ActionController::RoutingError.new("Robot #{options[:name]} Not Found") if robot_settings.nil?
      robot_class = (robot_settings[:class]||'Robots::Robot').constantize
      robot_class.new(robot_settings.merge(options))
    end

    class_inheritable_reader :attributes
    write_inheritable_attribute :attributes, [:api, :user_uuid, :layout, :beds, :name, :id, :location]

    def beds=(new_beds)
      beds = ActiveSupport::OrderedHash.new {|beds,barcode| InvalidBed.new(barcode) }
      new_beds.sort_by {|id,bed| bed.order }.each do |id,bed|
        beds[id] = Bed.new(bed.merge({:api=>api, :user_uuid=>user_uuid, :robot=>self }))
      end
      @beds = beds
    end
    private :beds=

    def perform_transfer(bed_settings)
      beds.each do |id, bed|
        bed.load(bed_settings[id]) if bed.has_transition?
        bed.valid? or raise BedError, bed.error_message
      end
      beds.values.each(&:transition)
    end

    def error_messages
      @error_messages||=[]
    end

    def error(bed, message)
      error_messages << "#{bed.label}: #{message}"
      false
    end

    def bed_error(bed)
      error_messages << bed.formatted_message
      false
    end

    def formatted_message
      error_messages.join(' ')
    end

    def verify(bed_contents)
      valid_plates = Hash[bed_contents.map do |bed_id,plate_barcode|
        beds[bed_id].load(plate_barcode)
        [bed_id, beds[bed_id].valid?||bed_error(beds[bed_id])]
      end]
      valid_parents = Hash[parents_and_position do |parent,position|
        beds[position].plate.try(:uuid) == parent.try(:uuid) || error(beds[position], parent.present? ?
          "Should contain #{parent.barcode.prefix}#{parent.barcode.number}." :
          "Could not match plate with expected child.")
      end]
      verified = valid_plates.merge(valid_parents) {|k,v1,v2| v1 && v2 }
      unless plates_compatible?
        bed_contents.keys.each {|k| verified[k] = false }
        error_messages << "#{bed_prefixes.to_sentence} can not be processed together."
      end
      {:beds=>verified,:valid=>verified.all?{|_,v| v},:message=>formatted_message}
    end

    def plates_compatible?
      bed_prefixes.count <= 1
    end

    def bed_prefixes
      beds.map {|id,bed| bed.plate.label.prefix unless bed.plate.nil?}.compact.uniq
    end

    def parents_and_position
      beds.map do |id, bed|
        next if bed.parent.nil?
        result = yield(bed.parent_plate,bed.parent)
        [id,result]
      end
    end
    private :parents_and_position

  end

end
