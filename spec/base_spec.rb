require 'spec_helper'

class BaseChronologicable < ActiveRecord::Base
  extend Chronological::Base

  base_timeframe :start_date_field => :started_on,
                 :start_time_field => :started_at,
                 :end_date_field   => :ended_on,
                 :end_time_field   => :ended_at
end

describe Chronological::Base do
  let(:started_at) { nil }
  let(:ended_at)   { nil }

  let(:chronologicable) do
    BaseChronologicable.new(
      :started_at => started_at,
      :ended_at   => ended_at
    )
  end

  describe '#started_on' do
    context 'when #started_at is set' do
      context 'to a string' do
        let(:started_at) { '2012-07-26 03:15:12' }

        it 'properly converts the date' do
          chronologicable.started_on.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
        end
      end

      context 'to a date' do
        let(:started_at) { Time.utc(2012, 7, 26, 3, 15, 12) }

        it 'properly converts the date' do
          chronologicable.started_on.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
        end
      end
    end

    context 'when #started_at is not set' do
      let(:started_at) { nil }

      it 'is nil' do
        chronologicable.started_on.should be_nil
      end
    end
  end

  describe '#ended_on' do
    context 'when #ended_at is set' do
      context 'to a string' do
        let(:ended_at) { '2012-07-26 03:15:12' }

        it 'properly converts the date' do
          chronologicable.ended_on.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
        end
      end

      context 'to a date' do
        let(:ended_at) { Time.utc(2012, 7, 26, 3, 15, 12) }

        it 'properly converts the date' do
          chronologicable.ended_on.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
        end
      end
    end

    context 'when #ended_at is not set' do
      let(:ended_at) { nil }

      it 'is nil' do
        chronologicable.ended_on.should be_nil
      end
    end
  end
end
