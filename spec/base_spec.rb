require 'spec_helper'

class BaseChronologicable < ActiveRecord::Base
  extend Chronological::Base

  base_timeframe :start_date_field => :started_on,
                 :start_time_field => :started_at,
                 :end_date_field   => :ended_on,
                 :end_time_field   => :ended_at

private
  def has_absolute_timeframe?
    started_at.present? && ended_at.present?
  end
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

  describe '#in_progress?', :timecop => true do
    let(:later) { Time.local(2012, 7, 26, 6, 0, 26) }
    let(:now)   { Time.local(2012, 7, 26, 6, 0, 25) }
    let(:past)  { Time.local(2012, 7, 26, 6, 0, 24) }

    before      { Timecop.freeze(now)             }

    context 'when it does not have an absolute timeframe' do
      before { chronologicable.should_receive(:has_absolute_timeframe?).and_return(false) }

      it 'is false' do
        chronologicable.should_not be_in_progress
      end
    end

    context 'when it has already started' do
      let(:started_at) { past }

      context 'and already ended' do
        let(:ended_at) { past }

        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      context 'and ends now' do
        let(:ended_at) { now }

        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      context 'and ends later' do
        let(:ended_at) { later }

        it 'is true' do
          chronologicable.should be_in_progress
        end
      end
    end

    context 'when there is a chronologicable that starts now' do
      let(:started_at) { now }

      context 'and ends now' do
        let(:ended_at) { now }

        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      context 'and ends later' do
        let(:ended_at) { later }

        it 'is true' do
          chronologicable.should be_in_progress
        end
      end
    end

    context 'when there is a chronologicable that has not yet started' do
      let(:started_at) { later }
      let(:ended_at)   { later }

      it 'is false' do
        chronologicable.should_not be_in_progress
      end
    end
  end
end
