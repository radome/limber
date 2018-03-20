# frozen_string_literal: true

require 'spec_helper'

# CreationForm is the base class for our forms
describe Limber::TagLayoutTemplate do
  has_a_working_api

  #:tag_layout_template_by_row
  #:tag_layout_template_by_quadrant

  subject(:tag_layout_template) { build template_factory }

  let(:plate_uuid) { SecureRandom.uuid }

  let(:plate) do
    build(:stock_plate, uuid: plate_uuid, state: 'passed', pool_sizes: [48, 48], &:populate_wells_with_pool)
  end

  let(:wells_json) { json :well_collection, size: 96 }

  before do
    stub_api_get plate_uuid, 'wells', body: wells_json
  end

  shared_examples 'a tag layout' do
    describe '#generate_tag_layout' do
      subject { tag_layout_template.coerce.generate_tag_layout(plate) }
      it { is_expected.to eq expected_layout }
    end
  end

  # rubocop:disable Metrics/LineLength
  # We mimic plate layout here, which seems preferable to arbitrary length limits.
  context 'by column' do
    let(:template_factory) { :tag_layout_template }
    let(:expected_layout) do
      {
        'A1' => [1,  1], 'A2' => [1, 9], 'A3' => [1, 17], 'A4' => [1, 25], 'A5' => [1, 33], 'A6' => [1, 41], 'A7' => [2, 49], 'A8' => [2, 57], 'A9' => [2, 65], 'A10' => [2, 73], 'A11' => [2, 81], 'A12' => [2, 89],
        'B1' => [1,  2], 'B2' => [1, 10], 'B3' => [1, 18], 'B4' => [1, 26], 'B5' => [1, 34], 'B6' => [1, 42], 'B7' => [2, 50], 'B8' => [2, 58], 'B9' => [2, 66], 'B10' => [2, 74], 'B11' => [2, 82], 'B12' => [2, 90],
        'C1' => [1,  3], 'C2' => [1, 11], 'C3' => [1, 19], 'C4' => [1, 27], 'C5' => [1, 35], 'C6' => [1, 43], 'C7' => [2, 51], 'C8' => [2, 59], 'C9' => [2, 67], 'C10' => [2, 75], 'C11' => [2, 83], 'C12' => [2, 91],
        'D1' => [1,  4], 'D2' => [1, 12], 'D3' => [1, 20], 'D4' => [1, 28], 'D5' => [1, 36], 'D6' => [1, 44], 'D7' => [2, 52], 'D8' => [2, 60], 'D9' => [2, 68], 'D10' => [2, 76], 'D11' => [2, 84], 'D12' => [2, 92],
        'E1' => [1,  5], 'E2' => [1, 13], 'E3' => [1, 21], 'E4' => [1, 29], 'E5' => [1, 37], 'E6' => [1, 45], 'E7' => [2, 53], 'E8' => [2, 61], 'E9' => [2, 69], 'E10' => [2, 77], 'E11' => [2, 85], 'E12' => [2, 93],
        'F1' => [1,  6], 'F2' => [1, 14], 'F3' => [1, 22], 'F4' => [1, 30], 'F5' => [1, 38], 'F6' => [1, 46], 'F7' => [2, 54], 'F8' => [2, 62], 'F9' => [2, 70], 'F10' => [2, 78], 'F11' => [2, 86], 'F12' => [2, 94],
        'G1' => [1,  7], 'G2' => [1, 15], 'G3' => [1, 23], 'G4' => [1, 31], 'G5' => [1, 39], 'G6' => [1, 47], 'G7' => [2, 55], 'G8' => [2, 63], 'G9' => [2, 71], 'G10' => [2, 79], 'G11' => [2, 87], 'G12' => [2, 95],
        'H1' => [1,  8], 'H2' => [1, 16], 'H3' => [1, 24], 'H4' => [1, 32], 'H5' => [1, 40], 'H6' => [1, 48], 'H7' => [2, 56], 'H8' => [2, 64], 'H9' => [2, 72], 'H10' => [2, 80], 'H11' => [2, 88], 'H12' => [2, 96]

      }
    end
    it_behaves_like 'a tag layout'
  end

  context 'by row' do
    let(:template_factory) { :tag_layout_template_by_row }
    let(:expected_layout) do
      {
        'A1' => [1,  1], 'A2' => [1, 2], 'A3' => [1, 3], 'A4' => [1, 4], 'A5' => [1, 5], 'A6' => [1, 6], 'A7' => [2, 7], 'A8' => [2, 8], 'A9' => [2, 9], 'A10' => [2, 10], 'A11' => [2, 11], 'A12' => [2, 12],
        'B1' => [1, 13], 'B2' => [1, 14], 'B3' => [1, 15], 'B4' => [1, 16], 'B5' => [1, 17], 'B6' => [1, 18], 'B7' => [2, 19], 'B8' => [2, 20], 'B9' => [2, 21], 'B10' => [2, 22], 'B11' => [2, 23], 'B12' => [2, 24],
        'C1' => [1, 25], 'C2' => [1, 26], 'C3' => [1, 27], 'C4' => [1, 28], 'C5' => [1, 29], 'C6' => [1, 30], 'C7' => [2, 31], 'C8' => [2, 32], 'C9' => [2, 33], 'C10' => [2, 34], 'C11' => [2, 35], 'C12' => [2, 36],
        'D1' => [1, 37], 'D2' => [1, 38], 'D3' => [1, 39], 'D4' => [1, 40], 'D5' => [1, 41], 'D6' => [1, 42], 'D7' => [2, 43], 'D8' => [2, 44], 'D9' => [2, 45], 'D10' => [2, 46], 'D11' => [2, 47], 'D12' => [2, 48],
        'E1' => [1, 49], 'E2' => [1, 50], 'E3' => [1, 51], 'E4' => [1, 52], 'E5' => [1, 53], 'E6' => [1, 54], 'E7' => [2, 55], 'E8' => [2, 56], 'E9' => [2, 57], 'E10' => [2, 58], 'E11' => [2, 59], 'E12' => [2, 60],
        'F1' => [1, 61], 'F2' => [1, 62], 'F3' => [1, 63], 'F4' => [1, 64], 'F5' => [1, 65], 'F6' => [1, 66], 'F7' => [2, 67], 'F8' => [2, 68], 'F9' => [2, 69], 'F10' => [2, 70], 'F11' => [2, 71], 'F12' => [2, 72],
        'G1' => [1, 73], 'G2' => [1, 74], 'G3' => [1, 75], 'G4' => [1, 76], 'G5' => [1, 77], 'G6' => [1, 78], 'G7' => [2, 79], 'G8' => [2, 80], 'G9' => [2, 81], 'G10' => [2, 82], 'G11' => [2, 83], 'G12' => [2, 84],
        'H1' => [1, 85], 'H2' => [1, 86], 'H3' => [1, 87], 'H4' => [1, 88], 'H5' => [1, 89], 'H6' => [1, 90], 'H7' => [2, 91], 'H8' => [2, 92], 'H9' => [2, 93], 'H10' => [2, 94], 'H11' => [2, 95], 'H12' => [2, 96]

      }
    end
    it_behaves_like 'a tag layout'
  end

  context 'by quadrant' do
    let(:template_factory) { :tag_layout_template_by_quadrant }
    let(:expected_layout) do
      {
        'A1' => [1,  1], 'A2' => [1,  1], 'A3' => [1,  5], 'A4' => [1, 5], 'A5' => [1,  9], 'A6' => [1,  9], 'A7' => [2, 13], 'A8' => [2, 13], 'A9' => [2, 17], 'A10' => [2, 17], 'A11' => [2, 21], 'A12' => [2, 21],
        'B1' => [1,  1], 'B2' => [1,  1], 'B3' => [1,  5], 'B4' => [1, 5], 'B5' => [1,  9], 'B6' => [1,  9], 'B7' => [2, 13], 'B8' => [2, 13], 'B9' => [2, 17], 'B10' => [2, 17], 'B11' => [2, 21], 'B12' => [2, 21],
        'C1' => [1,  2], 'C2' => [1,  2], 'C3' => [1,  6], 'C4' => [1, 6], 'C5' => [1, 10], 'C6' => [1, 10], 'C7' => [2, 14], 'C8' => [2, 14], 'C9' => [2, 18], 'C10' => [2, 18], 'C11' => [2, 22], 'C12' => [2, 22],
        'D1' => [1,  2], 'D2' => [1,  2], 'D3' => [1,  6], 'D4' => [1, 6], 'D5' => [1, 10], 'D6' => [1, 10], 'D7' => [2, 14], 'D8' => [2, 14], 'D9' => [2, 18], 'D10' => [2, 18], 'D11' => [2, 22], 'D12' => [2, 22],
        'E1' => [1,  3], 'E2' => [1,  3], 'E3' => [1,  7], 'E4' => [1, 7], 'E5' => [1, 11], 'E6' => [1, 11], 'E7' => [2, 15], 'E8' => [2, 15], 'E9' => [2, 19], 'E10' => [2, 19], 'E11' => [2, 23], 'E12' => [2, 23],
        'F1' => [1,  3], 'F2' => [1,  3], 'F3' => [1,  7], 'F4' => [1, 7], 'F5' => [1, 11], 'F6' => [1, 11], 'F7' => [2, 15], 'F8' => [2, 15], 'F9' => [2, 19], 'F10' => [2, 19], 'F11' => [2, 23], 'F12' => [2, 23],
        'G1' => [1,  4], 'G2' => [1,  4], 'G3' => [1,  8], 'G4' => [1, 8], 'G5' => [1, 12], 'G6' => [1, 12], 'G7' => [2, 16], 'G8' => [2, 16], 'G9' => [2, 20], 'G10' => [2, 20], 'G11' => [2, 24], 'G12' => [2, 24],
        'H1' => [1,  4], 'H2' => [1,  4], 'H3' => [1,  8], 'H4' => [1, 8], 'H5' => [1, 12], 'H6' => [1, 12], 'H7' => [2, 16], 'H8' => [2, 16], 'H9' => [2, 20], 'H10' => [2, 20], 'H11' => [2, 24], 'H12' => [2, 24]

      }
    end
    it_behaves_like 'a tag layout'
  end
  # rubocop:enable Metrics/LineLength
end
