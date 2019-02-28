# frozen_string_literal: true

module Limber::TagLayoutTemplate::InColumns
  def group_wells_of_plate(plate)
    group_wells(plate) do |well_location_pool_pair|
      WellHelpers.column_order(plate.size).map do |row_column|
        well_location_pool_pair.call(row_column)
      end
    end
  end
  private :group_wells_of_plate

  # Returns the tag index for the primary (i7) tag
  # That is the one laid out in columns with four copies of each
  # i5 follows the same pattern, but isn't actually shown in limber
  #
  # @param row [Integer] Zero indexed row co-ordinate of the well
  # @param column [Integer] Zero-indexed column co-ordinate of the well
  # @param scale [Integer] The number of times each tag is repeated in a given row/column.
  #                        eg. 2 for quad stamps.
  # @param height [Integer] The number of rows on a plate
  # @param _width [Integer] The number of columns on a plate (unused)
  #
  # @return [Integer] The index of the tag to use for the well
  def primary_index(row, column, scale, height, _width)
    tag_col = (column / scale)
    tag_row = (row / scale)
    tag_row + (height / scale * tag_col)
  end
end
