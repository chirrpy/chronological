require 'spec_helper'

class RelativeChronologicable < ActiveRecord::Base
  include Chronological::RelativeTimeframe

  relative_timeframe :start     => :starting_offset,
                     :end       => :ending_offset,
                     :base_utc  => :base_datetime_utc
end

describe Chronological::RelativeTimeframe do
  let(:now)         { Time.local(2012, 7, 26, 6, 0, 0)  }
  let(:base_time)   { Time.local(2012, 7, 26, 6, 0, 30) }

  before            { Timecop.freeze(now)               }

  let(:chronologicable) do
    RelativeChronologicable.create(
      :starting_offset      => starting_offset,
      :ending_offset        => ending_offset,
      :base_datetime_utc    => base_time)
  end

  context 'when it is not scheduled' do
    let(:chronologicable) { RelativeChronologicable.new }

    before { chronologicable.should_receive(:has_absolute_timeframe?).and_return false }

    it 'is not active' do
      chronologicable.should_not be_active
    end
  end

  describe '#duration' do
    context 'when the starting offset is set' do
      let(:starting_offset) { 6263 }

      context 'and the ending offset is set' do
        let(:ending_offset) { 0 }

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

      context 'but the ending offset is not set' do
        let(:ending_offset) { nil }

        it 'is nil' do
          chronologicable.duration.should eql Hash.new
        end
      end
    end

    context 'when the starting offset is not set' do
      let(:starting_offset) { nil }

      context 'but the ending offset is set' do
        let(:ending_offset) { 0 }

        it 'is nil' do
          chronologicable.duration.should eql Hash.new
        end
      end

      context 'and the ending offset is not set' do
        let(:ending_offset) { nil }

        it 'is nil' do
          chronologicable.duration.should eql Hash.new
        end
      end
    end
  end

  describe '#started_at_utc' do
    let(:ending_offset) { 'anything' }

    context 'when the starting offset is set' do
      let(:starting_offset) { 30 }

      context 'but the base time is not set' do
        let(:base_time) { nil }

        it 'is nil' do
          chronologicable.started_at_utc.should be_nil
        end
      end

      context 'and the base time is set' do
        let(:base_time)   { Time.local(2012, 7, 26, 6, 0, 30) }

        it 'is the proper offset calculation' do
          chronologicable.started_at_utc.should eql Time.local(2012, 7, 26, 6, 0, 0)
        end
      end
    end

    context 'when the starting offset is not set' do
      let(:starting_offset) { nil }

      it 'is nil' do
        chronologicable.started_at_utc.should be_nil
      end
    end
  end

  describe '#ended_at_utc' do
    let(:starting_offset) { 'anything' }

    context 'when the ending offset is set' do
      let(:ending_offset) { 30 }

      context 'but the base time is not set' do
        let(:base_time) { nil }

        it 'is nil' do
          chronologicable.ended_at_utc.should be_nil
        end
      end

      context 'and the base time is set' do
        let(:base_time)   { Time.local(2012, 7, 26, 6, 0, 30) }

        it 'is the proper offset calculation' do
          chronologicable.ended_at_utc.should eql Time.local(2012, 7, 26, 6, 0, 0)
        end
      end
    end

    context 'when the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'is nil' do
        chronologicable.ended_at_utc.should be_nil
      end
    end
  end

  describe '#started_on_utc' do
    let(:chronologicable) { RelativeChronologicable.new }

    context 'when the starting time field is set' do
      before { chronologicable.should_receive(:started_at_utc).twice.and_return Time.local(2012, 7, 26, 6, 0, 0) }

      it 'is the proper offset calculation' do
        chronologicable.started_on_utc.should eql Time.local(2012, 7, 26, 6, 0, 0).to_date
      end
    end

    context 'when the starting offset is not set' do
      before { chronologicable.should_receive(:started_at_utc).and_return nil }

      it 'is nil' do
        chronologicable.started_on_utc.should be_nil
      end
    end
  end

  describe '#ended_on_utc' do
    let(:chronologicable) { RelativeChronologicable.new }

    context 'when the ending time field is set' do
      before { chronologicable.should_receive(:ended_at_utc).twice.and_return Time.local(2012, 7, 26, 6, 0, 0) }

      it 'is the proper offset calculation' do
        chronologicable.ended_on_utc.should eql Time.local(2012, 7, 26, 6, 0, 0).to_date
      end
    end

    context 'when the ending offset is not set' do
      before { chronologicable.should_receive(:ended_at_utc).and_return nil }

      it 'is nil' do
        chronologicable.ended_on_utc.should be_nil
      end
    end
  end

  context 'when the base time is not set' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 0) }
    let(:base_time)       { nil }

    context 'but the starting offset is set' do
      let(:starting_offset) { 30 }

      context 'and the ending offset is set' do
        let(:ending_offset) { 0 }

        it 'is not scheduled' do
          chronologicable.should_not be_scheduled
        end

        it 'is partially scheduled' do
          chronologicable.should be_partially_scheduled
        end
      end

      context 'and the ending offset is not set' do
        let(:ending_offset) { nil }

        it 'is not scheduled' do
          chronologicable.should_not be_scheduled
        end

        it 'is partially scheduled' do
          chronologicable.should be_partially_scheduled
        end
      end
    end

    context 'and the starting offset is not set' do
      let(:starting_offset) { nil }

      context 'but the ending offset is set' do
        let(:ending_offset) { 0 }

        it 'is not scheduled' do
          chronologicable.should_not be_scheduled
        end

        it 'is partially scheduled' do
          chronologicable.should be_partially_scheduled
        end
      end
    end

    context 'and neither of the offsets is set' do
      let(:starting_offset) { nil }
      let(:ending_offset)   { nil }

      it 'is not scheduled' do
        chronologicable.should_not be_scheduled
      end

      it 'is not partially scheduled' do
        chronologicable.should_not be_partially_scheduled
      end
    end
  end

  context 'when the starting offset is not set' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 0) }
    let(:starting_offset) { nil }

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'is not scheduled' do
        chronologicable.should_not be_scheduled
      end

      it 'is partially scheduled' do
        chronologicable.should be_partially_scheduled
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset)   { 0 }

      it 'is not scheduled' do
        chronologicable.should_not be_scheduled
      end

      it 'is partially scheduled' do
        chronologicable.should be_partially_scheduled
      end
    end
  end

  context 'when the starting offset is set' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 0) }
    let(:starting_offset) { 30 }

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'is not active' do
        chronologicable.should_not be_active
      end

      it 'is not scheduled' do
        chronologicable.should_not be_scheduled
      end

      it 'is partially scheduled' do
        chronologicable.should be_partially_scheduled
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset)   { 0 }

      it 'is scheduled' do
        chronologicable.should be_scheduled
      end

      it 'is partially scheduled' do
        chronologicable.should be_partially_scheduled
      end
    end
  end

  context 'when it is currently a time before the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 5, 59, 59) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not active' do
        chronologicable.should_not be_active
      end
    end
  end

  context 'when it is currently a time the same as the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 0) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 29 }

      it 'is active' do
        chronologicable.should be_active
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not active' do
        chronologicable.should_not be_active
      end
    end
  end

  context 'when it is currently a time after the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 2) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 27 }

      it 'is active' do
        chronologicable.should be_active
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 28 }

      it 'is not active' do
        chronologicable.should_not be_active
      end
    end

    context 'and after the ending offset' do
      let(:ending_offset) { 29 }

      it 'is not active' do
        chronologicable.should_not be_active
      end
    end
  end
end
