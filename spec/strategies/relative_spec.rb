require 'spec_helper'

class RelativeChronologicable < ActiveRecord::Base
  extend Chronological

  timeframe type:             :relative,
            starting_offset:  :starting_offset,
            ending_offset:    :ending_offset,
            base_of_offset:   :base_datetime_utc
end

describe Chronological::RelativeStrategy, :timecop => true do
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

  describe '.by_date' do
    before { RelativeChronologicable.delete_all }

    context 'when there are two chronologicables that start at the same time' do
      context 'but end at different times' do
        let!(:chronologicable_1) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 2) }
        let!(:chronologicable_2) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 1) }

        context 'when no option is passed' do
          it 'properly sorts them in ascending order' do
            RelativeChronologicable.by_date.first.should  eql chronologicable_1
            RelativeChronologicable.by_date.last.should   eql chronologicable_2
          end
        end

        context 'when the :desc option is passed' do
          it 'sorts them backwards by the start date' do
            RelativeChronologicable.by_date(:desc).first.should  eql chronologicable_2
            RelativeChronologicable.by_date(:desc).last.should   eql chronologicable_1
          end
        end
      end

      context 'and end at the same time' do
        let!(:chronologicable_1) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 2) }
        let!(:chronologicable_2) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 2) }

        describe '.by_date' do
          context 'when in ascending order' do
            it 'does not matter what order they are in as long as they are all there' do
              RelativeChronologicable.by_date.should  include chronologicable_1
              RelativeChronologicable.by_date.should  include chronologicable_2
            end
          end

          context 'when in descending order' do
            it 'does not matter what order they are in as long as they are all there' do
              RelativeChronologicable.by_date(:desc).should  include chronologicable_1
              RelativeChronologicable.by_date(:desc).should  include chronologicable_2
            end
          end
        end
      end
    end

    context 'when there are two chronologicables that start at different times' do
      context 'and end at different times' do
        let!(:chronologicable_1) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 2) }
        let!(:chronologicable_2) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 2,  :ending_offset => 1) }

        context 'when in ascending order' do
          it 'sorts them by the start date' do
            RelativeChronologicable.by_date.first.should  eql chronologicable_1
            RelativeChronologicable.by_date.last.should   eql chronologicable_2
          end
        end

        context 'when in descending order' do
          it 'sorts them backwards by the start date' do
            RelativeChronologicable.by_date(:desc).first.should  eql chronologicable_2
            RelativeChronologicable.by_date(:desc).last.should   eql chronologicable_1
          end
        end
      end

      context 'but end at the same time' do
        let!(:chronologicable_1) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 1) }
        let!(:chronologicable_2) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 2,  :ending_offset => 1) }

        context 'when in ascending order' do
          it 'sorts them by the start date' do
            RelativeChronologicable.by_date.first.should  eql chronologicable_1
            RelativeChronologicable.by_date.last.should   eql chronologicable_2
          end
        end

        context 'when in descending order' do
          it 'sorts them backwards by the start date' do
            RelativeChronologicable.by_date(:desc).first.should  eql chronologicable_2
            RelativeChronologicable.by_date(:desc).last.should   eql chronologicable_1
          end
        end
      end
    end
  end

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
        chronologicable.started_at.should be_nil
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
        chronologicable.started_at.should be_nil
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 0 }

      it 'does not have a end time' do
        chronologicable.ended_at.should be_nil
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have a end time' do
        chronologicable.ended_at.should be_nil
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
        chronologicable.started_at.should be_nil
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
        chronologicable.started_at.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 30 }

      it 'calculates the correct end time' do
        chronologicable.ended_at.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have a end time' do
        chronologicable.ended_at.should be_nil
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
