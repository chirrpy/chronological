require 'spec_helper'

class RelativeChronologicable < ActiveRecord::Base
  include Chronological::RelativeTimeframe

  relative_timeframe start:    :starting_offset,
                     end:      :ending_offset,
                     base_utc: :base_datetime_utc
end

describe Chronological::RelativeTimeframe do
  let(:now)             { nil }
  let(:starting_offset) { nil }
  let(:ending_offset)   { nil }
  let(:base_time)       { nil }

  let!(:chronologicable) do
    RelativeChronologicable.create(
      starting_offset:    starting_offset,
      ending_offset:      ending_offset,
      base_datetime_utc:  base_time)
  end

  before { Timecop.freeze(now) }

  it { RelativeChronologicable.new.respond_to?(:active?).should  be_true }

  it { RelativeChronologicable.respond_to?(:active?).should      be_true }
  it { RelativeChronologicable.respond_to?(:active).should       be_true }

  context 'when the base time is not set' do
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

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
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

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time' do
        chronologicable.started_at_utc.should be_nil
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

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time' do
        chronologicable.started_at_utc.should be_nil
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 0 }

      it 'does not have a end time' do
        chronologicable.ended_at_utc.should be_nil
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have a end time' do
        chronologicable.ended_at_utc.should be_nil
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

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when the base time is set' do
    let(:now)         { Time.local(2012, 7, 26, 6, 0, 0)  }
    let(:base_time)   { Time.local(2012, 7, 26, 6, 0, 30) }

    context 'when the starting offset is not set' do
      let(:starting_offset) { nil }

      context 'and the ending offset is not set' do
        let(:ending_offset) { nil }

        it 'is not scheduled' do
          chronologicable.should_not be_scheduled
        end

        it 'is partially scheduled' do
          chronologicable.should be_partially_scheduled
        end

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
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

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time' do
        chronologicable.started_at_utc.should be_nil
      end
    end

    context 'when the starting offset is set' do
      let(:starting_offset) { 30 }

      context 'and the ending offset is not set' do
        let(:ending_offset) { nil }

        it 'is not scheduled' do
          chronologicable.should_not be_scheduled
        end

        it 'is partially scheduled' do
          chronologicable.should be_partially_scheduled
        end

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
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

        it 'is included in the in progress list' do
          RelativeChronologicable.in_progress.should include chronologicable
        end

        it 'marks the list as in progress' do
          RelativeChronologicable.should be_in_progress
        end
      end

      it 'calculates the correct start time' do
        chronologicable.started_at_utc.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 30 }

      it 'calculates the correct end time' do
        chronologicable.ended_at_utc.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have a end time' do
        chronologicable.ended_at_utc.should be_nil
      end
    end
  end

  context 'when it is currently a time before the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 5, 59, 59) }
    let(:base_time)       { Time.local(2012, 7, 26, 6,  0, 30) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when it is currently a time the same as the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 0) }
    let(:base_time)       { Time.local(2012, 7, 26, 6,  0, 30) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 29 }

      it 'is included in the in progress list' do
        RelativeChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        RelativeChronologicable.should be_in_progress
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when it is currently a time after the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 6, 0, 2) }
    let(:base_time)       { Time.local(2012, 7, 26, 6,  0, 30) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 27 }

      it 'is included in the in progress list' do
        RelativeChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        RelativeChronologicable.should be_in_progress
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 28 }

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end

    context 'and after the ending offset' do
      let(:ending_offset) { 29 }

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end
  end
end
