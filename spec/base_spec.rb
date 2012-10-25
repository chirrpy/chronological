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

  describe '#duration' do
    context 'when the chronologicable represents something with a duration' do
      before { chronologicable.should_receive(:duration_in_seconds).any_number_of_times.and_return(6263) }

      it 'is a hash with the correct hours' do
        chronologicable.duration[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        chronologicable.duration[:minutes].should eql 44
      end

      it 'is a hash with the correct seconds' do
        chronologicable.duration[:seconds].should eql 23
      end
    end

    context 'when the chronologicable represents something with an even second time duration' do
      before { chronologicable.should_receive(:duration_in_seconds).any_number_of_times.and_return(6240) }

      it 'is a hash with the correct hours' do
        chronologicable.duration[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        chronologicable.duration[:minutes].should eql 44
      end

      it 'is a hash with the correct seconds' do
        chronologicable.duration[:seconds].should eql 0
      end
    end

    context 'when the chronologicable represents something with an even minute time duration' do
      before { chronologicable.should_receive(:duration_in_seconds).any_number_of_times.and_return(3600) }

      it 'is a hash with the correct hours' do
        chronologicable.duration[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        chronologicable.duration[:minutes].should eql 0
      end

      it 'is a hash with the correct seconds' do
        chronologicable.duration[:seconds].should eql 0
      end
    end

    context 'when the chronologicable represents something with a zero duration' do
      before { chronologicable.should_receive(:duration_in_seconds).any_number_of_times.and_return(0) }

      it 'is a hash with the correct hours' do
        chronologicable.duration[:hours].should eql 0
      end

      it 'is a hash with the correct minutes' do
        chronologicable.duration[:minutes].should eql 0
      end

      it 'is a hash with the correct seconds' do
        chronologicable.duration[:seconds].should eql 0
      end
    end

    context 'when duration in seconds returns an empty value' do
      before { chronologicable.should_receive(:duration_in_seconds).and_return(nil) }

      it 'is an empty hash' do
        chronologicable.duration.should eql Hash.new
      end
    end
  end
end
