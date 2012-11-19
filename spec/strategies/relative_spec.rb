require 'spec_helper'

class RelativeChronologicable < ActiveRecord::Base
  extend Chronological

  timeframe type:             :relative,
            starting_offset:  :starting_offset,
            ending_offset:    :ending_offset,
            base_of_offset:   :base_datetime_utc
end

class RelativeChronologicableWithTimeZone < ActiveRecord::Base
  extend Chronological

  timeframe type:             :relative,
            starting_offset:  :starting_offset,
            ending_offset:    :ending_offset,
            base_of_offset:   :base_datetime_utc,
            time_zone:        :time_zone
end

class RelativeChronologicalWithOverriddenTime < ActiveRecord::Base
  extend Chronological

  set_table_name 'relative_chronologicables'

  timeframe type:             :relative,
            starting_offset:  :starting_offset,
            ending_offset:    :ending_offset,
            base_of_offset:   :base_datetime_utc,
            starting_time:    :foobar_starting_time,
            ending_time:      :foobar_ending_time,
            starting_date:    :foobar_starting_date,
            ending_date:      :foobar_ending_date
end

describe Chronological::RelativeStrategy, :timecop => true do
  let(:now)             { nil }
  let(:starting_offset) { nil }
  let(:ending_offset)   { nil }
  let(:base_time)       { nil }
  let(:time_zone)       { nil }

  let!(:chronologicable) do
    RelativeChronologicable.create(
      starting_offset:    starting_offset,
      ending_offset:      ending_offset,
      base_datetime_utc:  base_time)
  end

  let!(:chronologicable_without_enabled_time_zone) do
    RelativeChronologicable.new(
      starting_offset:    starting_offset,
      ending_offset:      ending_offset,
      base_datetime_utc:  base_time)
  end

  let!(:chronologicable_with_enabled_time_zone) do
    RelativeChronologicableWithTimeZone.new(
      starting_offset:    starting_offset,
      ending_offset:      ending_offset,
      base_datetime_utc:  base_time,
      time_zone:          time_zone)
  end

  let(:chronologicable_with_overridden_time) do
    RelativeChronologicalWithOverriddenTime.new
  end

  it { chronologicable_with_overridden_time.should respond_to(:foobar_starting_time) }
  it { chronologicable_with_overridden_time.should respond_to(:foobar_ending_time)   }
  it { chronologicable_with_overridden_time.should respond_to(:foobar_starting_date) }
  it { chronologicable_with_overridden_time.should respond_to(:foobar_ending_date)   }

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

  describe '.by_duration' do
    before { RelativeChronologicable.delete_all }

    context 'when there are two chronologicables that are different durations' do
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

    context 'when there are two chronologicables that are the same duration' do
      let!(:chronologicable_1) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 1) }
      let!(:chronologicable_2) { RelativeChronologicable.create(:base_datetime_utc => Time.now, :starting_offset => 3, :ending_offset => 1) }

      context 'when no option is passed' do
        it 'does not matter what order they are in' do
          RelativeChronologicable.by_date.should  include chronologicable_1
          RelativeChronologicable.by_date.should  include chronologicable_2
        end
      end

      context 'when the :desc option is passed' do
        it 'does not matter what order they are in' do
          RelativeChronologicable.by_date(:desc).should  include chronologicable_1
          RelativeChronologicable.by_date(:desc).should  include chronologicable_2
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

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
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

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time when called directly' do
        chronologicable.started_at.should be_nil
      end

      it 'has the proper start time when a base is passed in' do
        chronologicable.started_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should eql Time.local(2012, 7, 26, 11, 59, 30)
      end
    end

    context 'and the starting offset is not set' do
      let(:starting_offset) { nil }

      context 'but the ending offset is set' do
        let(:ending_offset) { 0 }

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time when called directly' do
        chronologicable.started_at.should be_nil
      end

      it 'does not have a start time when a base is passed in' do
        chronologicable.started_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should be_nil
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 0 }

      it 'does not have an end time when called directly' do
        chronologicable.ended_at.should be_nil
      end

      it 'calculates the correct end time when a base is passed in' do
        chronologicable.ended_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should eql Time.local(2012, 7, 26, 12, 0, 0)
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have an end time when called directly' do
        chronologicable.ended_at.should be_nil
      end

      it 'does not have an end time when a base is passed in' do
        chronologicable.ended_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should be_nil
      end
    end

    context 'and neither of the offsets is set' do
      let(:starting_offset) { nil }
      let(:ending_offset)   { nil }

      context 'when the time zone is not set' do
        let(:time_zone) { nil }

        context 'and the time zone check is enabled' do
          it 'is not scheduled' do
            chronologicable_with_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_with_enabled_time_zone.should_not be_partially_scheduled
          end
        end

        context 'and the time zone check is not enabled' do
          it 'is not scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_partially_scheduled
          end
        end
      end

      context 'when the time zone is blank' do
        let(:time_zone) { '' }

        context 'and the time zone check is enabled' do
          it 'is not scheduled' do
            chronologicable_with_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_with_enabled_time_zone.should_not be_partially_scheduled
          end
        end

        context 'and the time zone check is not enabled' do
          it 'is not scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_partially_scheduled
          end
        end
      end

      context 'when the time zone is set' do
        let(:time_zone) { 'Alaska' }

        context 'and the time zone check is enabled' do
          it 'is not scheduled' do
            chronologicable_with_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_with_enabled_time_zone.should be_partially_scheduled
          end
        end

        context 'and the time zone check is not enabled' do
          it 'is not scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_without_enabled_time_zone.should_not be_partially_scheduled
          end
        end
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

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
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

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        it 'is not included in the in progress list' do
          RelativeChronologicable.in_progress.should_not include chronologicable
        end

        it 'does not mark the list as in progress' do
          RelativeChronologicable.should_not be_in_progress
        end
      end

      it 'does not have a start time when called directly' do
        chronologicable.started_at.should be_nil
      end

      it 'does not have a start time when a base is passed in' do
        chronologicable.started_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should be_nil
      end
    end

    context 'when the starting offset is set' do
      let(:starting_offset) { 30 }

      context 'and the ending offset is not set' do
        let(:ending_offset) { nil }

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
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

        context 'when the time zone is not set' do
          let(:time_zone) { nil }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is blank' do
          let(:time_zone) { '' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'when the time zone is set' do
          let(:time_zone) { 'Alaska' }

          context 'and the time zone check is enabled' do
            it 'is not scheduled' do
              chronologicable_with_enabled_time_zone.should be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end

          context 'and the time zone check is not enabled' do
            it 'is not scheduled' do
              chronologicable_without_enabled_time_zone.should be_scheduled
            end

            it 'is partially scheduled' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        it 'is included in the in progress list' do
          RelativeChronologicable.in_progress.should include chronologicable
        end

        it 'marks the list as in progress' do
          RelativeChronologicable.should be_in_progress
        end
      end

      it 'calculates the correct start time when called directly' do
        chronologicable.started_at.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end

      it 'calculates the correct start time when a base is passed in' do
        chronologicable.started_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should eql Time.local(2012, 7, 26, 11, 59, 30)
      end
    end

    context 'and the ending offset is set' do
      let(:ending_offset) { 30 }

      it 'calculates the correct end time when called directly' do
        chronologicable.ended_at.should eql Time.local(2012, 7, 26, 6, 0, 0)
      end

      it 'calculates the correct end time when a base is passed in' do
        chronologicable.ended_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should eql Time.local(2012, 7, 26, 11, 59, 30)
      end
    end

    context 'and the ending offset is not set' do
      let(:ending_offset) { nil }

      it 'does not have a end time when called directly' do
        chronologicable.ended_at.should be_nil
      end

      it 'does not have an end time when a base is passed in' do
        chronologicable.ended_at(:base_of => Time.local(2012, 7, 26, 12, 0, 0)).should be_nil
      end
    end
  end

  context 'when it is currently a time before the starting offset' do
    let(:now)             { Time.local(2012, 7, 26, 5, 59, 59) }
    let(:base_time)       { Time.local(2012, 7, 26, 6,  0, 30) }
    let(:starting_offset) { 30 }

    context 'and before the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not started when called directly' do
        chronologicable.should_not be_started
      end

      it 'is started if the base time is overridden to a time before the offset plus "now"' do
        chronologicable.should be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is not included in the started list' do
        RelativeChronologicable.started.should_not include chronologicable
      end

      it 'is not included in the ended list' do
        RelativeChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should include chronologicable
      end

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

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not started if the base time is overridden to a time after the offset plus "now"' do
        chronologicable.should_not be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is included in the started list' do
        RelativeChronologicable.started.should include chronologicable
      end

      it 'is not included in the ended list' do
        RelativeChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should include chronologicable
      end

      it 'is included in the in progress list' do
        RelativeChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        RelativeChronologicable.should be_in_progress
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 30 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not started if the base time is overridden to a time after the offset plus "now"' do
        chronologicable.should_not be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is included in the started list' do
        RelativeChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        RelativeChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should_not include chronologicable
      end

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

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not started if the base time is overridden to a time after the offset plus "now"' do
        chronologicable.should_not be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 33))
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 29))
      end

      it 'is included in the started list' do
        RelativeChronologicable.started.should include chronologicable
      end

      it 'is not included in the ended list' do
        RelativeChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should include chronologicable
      end

      it 'is included in the in progress list' do
        RelativeChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        RelativeChronologicable.should be_in_progress
      end
    end

    context 'and the same as the ending offset' do
      let(:ending_offset) { 28 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not started if the base time is overridden to a time after the offset plus "now"' do
        chronologicable.should_not be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 33))
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 31))
      end

      it 'is included in the started list' do
        RelativeChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        RelativeChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should_not include chronologicable
      end

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end

    context 'and after the ending offset' do
      let(:ending_offset) { 29 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not started if the base time is overridden to a time after the offset plus "now"' do
        chronologicable.should_not be_started(:base_of => Time.local(2012, 7, 26, 6,  0, 33))
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should_not be_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 32))
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is not not yet ended if the base time is overridden to a time on or after the offset plus "now"' do
        chronologicable.should be_not_yet_ended(:base_of => Time.local(2012, 7, 26, 6,  0, 32))
      end

      it 'is included in the started list' do
        RelativeChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        RelativeChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        RelativeChronologicable.not_yet_ended.should_not include chronologicable
      end

      it 'is not included in the in progress list' do
        RelativeChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        RelativeChronologicable.should_not be_in_progress
      end
    end
  end
end
