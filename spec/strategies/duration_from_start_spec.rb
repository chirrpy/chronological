require 'spec_helper'

class DurationFromStartChronologicable < ActiveRecord::Base
  extend Chronological

  timeframe type:             :duration_from_start,
            starting_time:    :started_at,
            duration:         :duration_in_seconds
end

class DurationFromStartChronologicableWithTimeZone < ActiveRecord::Base
  extend Chronological

  timeframe type:             :duration_from_start,
            starting_time:    :started_at,
            duration:         :duration_in_seconds,
            time_zone:        :time_zone
end

class DurationFromStartChronologicalWithOverriddenTime < ActiveRecord::Base
  extend Chronological

  set_table_name 'duration_from_start_chronologicables'

  timeframe type:             :duration_from_start,
            starting_time:    :started_at,
            duration:         :duration_in_seconds,
            ending_time:      :foobar_ending_time,
            starting_date:    :foobar_starting_date,
            ending_date:      :foobar_ending_date
end

describe Chronological::DurationFromStartStrategy do
  let(:later)               { Time.local(2012, 7, 26, 6, 0, 26) }
  let(:now)                 { Time.local(2012, 7, 26, 6, 0, 25) }
  let(:past)                { Time.local(2012, 7, 26, 6, 0, 24) }

  let(:started_at)          { nil }
  let(:duration_in_seconds) { nil }
  let(:time_zone)           { nil }

  before(:each)             { Timecop.freeze(now) }
  after(:each)              { Timecop.return }

  let!(:chronologicable) do
    DurationFromStartChronologicable.create(
      started_at:           started_at,
      duration_in_seconds:  duration_in_seconds)
  end

  let!(:chronologicable_without_enabled_time_zone) do
    DurationFromStartChronologicable.new(
      started_at:           started_at,
      duration_in_seconds:  duration_in_seconds)
  end

  let!(:chronologicable_with_enabled_time_zone) do
    DurationFromStartChronologicableWithTimeZone.new(
      started_at:           started_at,
      duration_in_seconds:  duration_in_seconds,
      time_zone:            time_zone)
  end

  let(:chronologicable_with_overridden_time) do
    DurationFromStartChronologicalWithOverriddenTime.new
  end

  it { chronologicable_with_overridden_time.should respond_to(:foobar_ending_time)   }
  it { chronologicable_with_overridden_time.should respond_to(:foobar_starting_date) }
  it { chronologicable_with_overridden_time.should respond_to(:foobar_ending_date)   }

  describe '.by_date' do
    before { DurationFromStartChronologicable.delete_all }

    context 'when there are two chronologicables that start at the same time' do
      context 'but end at different times' do
        let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }
        let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 2) }

        context 'when no option is passed' do
          it 'properly sorts them in ascending order' do
            DurationFromStartChronologicable.by_date.first.should  eql chronologicable_1
            DurationFromStartChronologicable.by_date.last.should   eql chronologicable_2
          end
        end

        context 'when the :desc option is passed' do
          it 'sorts them backwards by the start date' do
            DurationFromStartChronologicable.by_date(:desc).first.should  eql chronologicable_2
            DurationFromStartChronologicable.by_date(:desc).last.should   eql chronologicable_1
          end
        end
      end

      context 'and end at the same time' do
        let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }
        let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }

        describe '.by_date' do
          context 'when in ascending order' do
            it 'does not matter what order they are in as long as they are all there' do
              DurationFromStartChronologicable.by_date.should  include chronologicable_1
              DurationFromStartChronologicable.by_date.should  include chronologicable_2
            end
          end

          context 'when in descending order' do
            it 'does not matter what order they are in as long as they are all there' do
              DurationFromStartChronologicable.by_date(:desc).should  include chronologicable_1
              DurationFromStartChronologicable.by_date(:desc).should  include chronologicable_2
            end
          end
        end
      end
    end

    context 'when there are two chronologicables that start at different times' do
      context 'and end at different times' do
        let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now,  :duration_in_seconds => 2) }
        let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => past, :duration_in_seconds => 1) }

        context 'when in ascending order' do
          it 'sorts them by the start date' do
            DurationFromStartChronologicable.by_date.first.should  eql chronologicable_2
            DurationFromStartChronologicable.by_date.last.should   eql chronologicable_1
          end
        end

        context 'when in descending order' do
          it 'sorts them backwards by the start date' do
            DurationFromStartChronologicable.by_date(:desc).first.should  eql chronologicable_1
            DurationFromStartChronologicable.by_date(:desc).last.should   eql chronologicable_2
          end
        end
      end

      context 'but end at the same time' do
        let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now,  :duration_in_seconds => 1) }
        let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => past, :duration_in_seconds => 2) }

        context 'when in ascending order' do
          it 'sorts them by the start date' do
            DurationFromStartChronologicable.by_date.first.should  eql chronologicable_2
            DurationFromStartChronologicable.by_date.last.should   eql chronologicable_1
          end
        end

        context 'when in descending order' do
          it 'sorts them backwards by the start date' do
            DurationFromStartChronologicable.by_date(:desc).first.should  eql chronologicable_1
            DurationFromStartChronologicable.by_date(:desc).last.should   eql chronologicable_2
          end
        end
      end
    end
  end

  describe '.by_duration' do
    before { DurationFromStartChronologicable.delete_all }

    context 'when there are two chronologicables that are different durations' do
      let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }
      let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 2) }

      context 'when no option is passed' do
        it 'properly sorts them in ascending order' do
          DurationFromStartChronologicable.by_date.first.should  eql chronologicable_1
          DurationFromStartChronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      context 'when the :desc option is passed' do
        it 'sorts them backwards by the start date' do
          DurationFromStartChronologicable.by_date(:desc).first.should  eql chronologicable_2
          DurationFromStartChronologicable.by_date(:desc).last.should   eql chronologicable_1
        end
      end
    end

    context 'when there are two chronologicables that are the same duration' do
      let!(:chronologicable_1) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }
      let!(:chronologicable_2) { DurationFromStartChronologicable.create(:started_at => now, :duration_in_seconds => 1) }

      context 'when no option is passed' do
        it 'does not matter what order they are in' do
          DurationFromStartChronologicable.by_date.should  include chronologicable_1
          DurationFromStartChronologicable.by_date.should  include chronologicable_2
        end
      end

      context 'when the :desc option is passed' do
        it 'does not matter what order they are in' do
          DurationFromStartChronologicable.by_date(:desc).should  include chronologicable_1
          DurationFromStartChronologicable.by_date(:desc).should  include chronologicable_2
        end
      end
    end
  end

  context 'when the start time is not set' do
    let(:started_at) { nil }

    context 'but the duration is set' do
      let(:duration_in_seconds) { 30 }

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
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end

    context 'and the duration is not set' do
      let(:duration_in_seconds) { nil }

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
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when the start time is set' do
    let(:started_at) { now }

    context 'and the duration is set' do
      let(:duration_in_seconds) { 30 }

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
          it 'is scheduled' do
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
          it 'is scheduled' do
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
          it 'is scheduled' do
            chronologicable_with_enabled_time_zone.should be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_with_enabled_time_zone.should be_partially_scheduled
          end
        end

        context 'and the time zone check is not enabled' do
          it 'is scheduled' do
            chronologicable_without_enabled_time_zone.should be_scheduled
          end

          it 'is partially scheduled' do
            chronologicable_without_enabled_time_zone.should be_partially_scheduled
          end
        end
      end

      it 'is included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should include chronologicable
      end

      it 'does mark the list as in progress' do
        DurationFromStartChronologicable.should be_in_progress
      end
    end

    context 'and the duration is not set' do
      let(:duration_in_seconds) { nil }

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
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when the base time is set' do
    let(:started_at) { Time.local(2012, 7, 26, 6, 0, 0)  }

    context 'and the duration is set' do
      let(:duration_in_seconds) { 30 }

      it 'calculates the correct end time when called directly' do
        chronologicable.ended_at.should eql Time.local(2012, 7, 26, 6, 0, 30)
      end
    end

    context 'and the duration is not set' do
      let(:duration_in_seconds) { nil }

      it 'does not have a end time when called directly' do
        chronologicable.ended_at.should be_nil
      end
    end
  end

  context 'when it is currently a time before the start date' do
    let(:now)         { Time.local(2012, 7, 26, 5, 59, 59) }
    let(:started_at)  { Time.local(2012, 7, 26, 6,  0,  0) }

    context 'and before the calculated end date' do
      let(:duration_in_seconds) { 30 }

      it 'is not started when called directly' do
        chronologicable.should_not be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is not included in the started list' do
        DurationFromStartChronologicable.started.should_not include chronologicable
      end

      it 'is not included in the ended list' do
        DurationFromStartChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should include chronologicable
      end

      it 'is not included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when it is currently a time the same as the start time' do
    let(:now)         { Time.local(2012, 7, 26, 6,  0,  0) }
    let(:started_at)  { Time.local(2012, 7, 26, 6,  0,  0) }

    context 'and before the calculated end date' do
      let(:duration_in_seconds) { 1 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is included in the started list' do
        DurationFromStartChronologicable.started.should include chronologicable
      end

      it 'is not included in the ended list' do
        DurationFromStartChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should include chronologicable
      end

      it 'is included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        DurationFromStartChronologicable.should be_in_progress
      end
    end

    context 'and the same as the calculated end date' do
      let(:duration_in_seconds) { 0 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is included in the started list' do
        DurationFromStartChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        DurationFromStartChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should_not include chronologicable
      end

      it 'is not included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end
  end

  context 'when it is currently a time after the start time' do
    let(:now)         { Time.local(2012, 7, 26, 6,  0,  2) }
    let(:started_at)  { Time.local(2012, 7, 26, 6,  0,  1) }

    context 'and before the calculated end date' do
      let(:duration_in_seconds) { 2 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should_not be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should be_not_yet_ended
      end

      it 'is included in the started list' do
        DurationFromStartChronologicable.started.should include chronologicable
      end

      it 'is not included in the ended list' do
        DurationFromStartChronologicable.ended.should_not include chronologicable
      end

      it 'is included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should include chronologicable
      end

      it 'is included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should include chronologicable
      end

      it 'marks the list as in progress' do
        DurationFromStartChronologicable.should be_in_progress
      end
    end

    context 'and the same as the calculated end date' do
      let(:duration_in_seconds) { 1 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is included in the started list' do
        DurationFromStartChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        DurationFromStartChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should_not include chronologicable
      end

      it 'is not included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end

    context 'and after the calculated end date' do
      let(:duration_in_seconds) { 0 }

      it 'is not started when called directly' do
        chronologicable.should be_started
      end

      it 'is not ended when called directly' do
        chronologicable.should be_ended
      end

      it 'is not yet ended when called directly' do
        chronologicable.should_not be_not_yet_ended
      end

      it 'is included in the started list' do
        DurationFromStartChronologicable.started.should include chronologicable
      end

      it 'is included in the ended list' do
        DurationFromStartChronologicable.ended.should include chronologicable
      end

      it 'is not included in the not yet ended list' do
        DurationFromStartChronologicable.not_yet_ended.should_not include chronologicable
      end

      it 'is not included in the in progress list' do
        DurationFromStartChronologicable.in_progress.should_not include chronologicable
      end

      it 'does not mark the list as in progress' do
        DurationFromStartChronologicable.should_not be_in_progress
      end
    end
  end
end
