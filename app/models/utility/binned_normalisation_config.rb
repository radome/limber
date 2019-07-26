# frozen_string_literal: true

module Utility
  # Handles the binned normalisation config functions.
  class BinnedNormalisationConfig
    include ActiveModel::Model
    require 'bigdecimal'

    attr_reader :config

    def initialize(config)
      @config = config
    end

    # This precision number could be extracted from config yml in future if needed.
    def number_decimal_places
      3
    end

    # Converts the string number to a big decimal
    def to_bigdecimal(s_number)
      BigDecimal(s_number, number_decimal_places)
    end

    # Returns target amount in ng from the config ynl
    def target_amount
      to_bigdecimal(@config['target_amount_ng'])
    end

    # Returns target volume from the config ynl
    def target_volume
      to_bigdecimal(@config['target_volume_ul'])
    end

    # Returns minimum source volume from the config yml
    def minimum_source_volume
      to_bigdecimal(@config['minimum_source_volume_ul'])
    end

    # Returns number of distinct bins in the config ynl
    def number_of_bins
      @config['bins'].size
    end

    # Returns the bins from the config ynl
    def bins_template
      @bins_template ||= configure_bins_template
    end

    private

    # Returns the bin minimum amount (ng) for a specific bin
    def bin_min(bin_template)
      to_bigdecimal((bin_template['min'] || -1.0))
    end

    # Returns the bin maximum amount (ng) for a specific bin
    def bin_max(bin_template)
      to_bigdecimal((bin_template['max'] || 'Infinity'))
    end

    # Returns an interpreted version of the bins configuration section with min max values
    def configure_bins_template
      @config['bins'].each_with_object([]) do |template, templates|
        templates << {
          'colour' => template.colour,
          'pcr_cycles' => template.pcr_cycles,
          'min' => bin_min(template),
          'max' => bin_max(template)
        }
      end
    end
  end
end
