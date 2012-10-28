require 'spec_helper'

class AbsoluteChronologicable < ActiveRecord::Base
  extend Chronological

  timeframe type:       :absolute,
            start_utc:  :started_at_utc,
            end_utc:    :ended_at_utc
end

class ChronologicableWithTimeZone < ActiveRecord::Base
  extend Chronological

  timeframe type:       :absolute,
            start_utc:  :started_at_utc,
            end_utc:    :ended_at_utc,
            time_zone:  :time_zone
end

describe Chronological::AbsoluteStrategy, :timecop => true do
  let(:later)      { Time.local(2012, 7, 26, 6, 0, 26) }
  let(:now)        { Time.local(2012, 7, 26, 6, 0, 25) }
  let(:past)       { Time.local(2012, 7, 26, 6, 0, 24) }

  let(:start_time) { nil }
  let(:end_time)   { nil }
  let(:time_zone)  { nil }

  before           { Timecop.freeze(now) }

  it { AbsoluteChronologicable.new.respond_to?(:starts_at_utc).should   be_true }
  it { AbsoluteChronologicable.new.respond_to?(:starting_at_utc).should be_true }
  it { AbsoluteChronologicable.new.respond_to?(:ends_at_utc).should     be_true }
  it { AbsoluteChronologicable.new.respond_to?(:ending_at_utc).should   be_true }
  it { AbsoluteChronologicable.new.respond_to?(:active?).should         be_true }

  it { AbsoluteChronologicable.respond_to?(:active?).should             be_true }
  it { AbsoluteChronologicable.respond_to?(:active).should              be_true }

  context 'when there are two chronologicables that start at the same time' do
    context 'but end at different times' do
      let!(:chronologicable_1) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => past }
      let!(:chronologicable_2) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => now }

      describe '.by_date' do
        it 'properly sorts them' do
          AbsoluteChronologicable.by_date.first.should  eql chronologicable_1
          AbsoluteChronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          AbsoluteChronologicable.by_date_reversed.first.should  eql chronologicable_2
          AbsoluteChronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end

    context 'and end at the same time' do
      let!(:chronologicable_1) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => now }
      let!(:chronologicable_2) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => now }

      describe '.by_date' do
        it 'does not matter what order they are in as long as they are all there' do
          AbsoluteChronologicable.by_date.should  include chronologicable_1
          AbsoluteChronologicable.by_date.should  include chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'does not matter what order they are in as long as they are all there' do
          AbsoluteChronologicable.by_date.should  include chronologicable_1
          AbsoluteChronologicable.by_date.should  include chronologicable_2
        end
      end
    end
  end

  context 'when there are two chronologicables that start at different times' do
    context 'and end at different times' do
      let!(:chronologicable_1) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => now }
      let!(:chronologicable_2) { AbsoluteChronologicable.create :started_at_utc => now,  :ended_at_utc => later }

      describe '.by_date' do
        it 'sorts them by the start date' do
          AbsoluteChronologicable.by_date.first.should  eql chronologicable_1
          AbsoluteChronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          AbsoluteChronologicable.by_date_reversed.first.should  eql chronologicable_2
          AbsoluteChronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end

    context 'but end at the same time' do
      let!(:chronologicable_1) { AbsoluteChronologicable.create :started_at_utc => past, :ended_at_utc => later }
      let!(:chronologicable_2) { AbsoluteChronologicable.create :started_at_utc => now,  :ended_at_utc => later }

      describe '.by_date' do
        it 'sorts them by the start date' do
          AbsoluteChronologicable.by_date.first.should  eql chronologicable_1
          AbsoluteChronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          AbsoluteChronologicable.by_date_reversed.first.should  eql chronologicable_2
          AbsoluteChronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end
  end

  context 'when dealing with one chronologicable' do
    let!(:chronologicable) do
      AbsoluteChronologicable.create(
        started_at_utc:  start_time,
        ended_at_utc:    end_time)
    end

    let!(:chronologicable_without_enabled_time_zone) do
      AbsoluteChronologicable.new(
        started_at_utc:  start_time,
        ended_at_utc:    end_time)
    end

    let!(:chronologicable_with_enabled_time_zone) do
      ChronologicableWithTimeZone.new(
        started_at_utc:  start_time,
        ended_at_utc:    end_time,
        time_zone:       time_zone)
    end

    context 'when a start time is set' do
      let(:start_time) { Time.now }

      context 'but no end time is set' do
        let(:end_time) { nil }

        context 'and no time zone is set' do
          let(:time_zone) { nil }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'and a time zone is set' do
          let(:time_zone) { ActiveSupport::TimeZone.new('Alaska') }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end
      end

      context 'an end time is set' do
        let(:end_time) { Time.now }

        context 'but no time zone is set' do
          let(:time_zone) { nil }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_scheduled
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'and a time zone is set' do
          let(:time_zone) { ActiveSupport::TimeZone.new('Alaska') }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_scheduled
              chronologicable_with_enabled_time_zone.should be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end
      end
    end

    context 'when an end time is set' do
      let(:end_time) { Time.now }

      context 'but no start time is set' do
        let(:start_time) { nil }

        describe '#scheduled?' do
          it 'is false' do
            chronologicable.should_not be_scheduled
          end
        end

        describe '#partially_scheduled?' do
          it 'is true' do
            chronologicable.should be_partially_scheduled
          end
        end

        context 'but no time zone is set' do
          let(:time_zone) { nil }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end

        context 'and a time zone is set' do
          let(:time_zone) { ActiveSupport::TimeZone.new('Alaska') }

          describe '#scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should_not be_scheduled
              chronologicable_with_enabled_time_zone.should_not be_scheduled
            end
          end

          describe '#partially_scheduled?' do
            it 'is correct' do
              chronologicable_without_enabled_time_zone.should be_partially_scheduled
              chronologicable_with_enabled_time_zone.should be_partially_scheduled
            end
          end
        end
      end
    end

    context 'when neither a start time nor an end time is set' do
      let(:start_time) { nil }
      let(:end_time)   { nil }

      describe '#scheduled?' do
        it 'is false' do
          chronologicable.should_not be_scheduled
        end
      end

      describe '#partially_scheduled?' do
        it 'is false' do
          chronologicable.should_not be_partially_scheduled
        end
      end
    end

    context 'when there is a chronologicable that has already started' do
      let(:start_time) { past }

      context 'and has already ended' do
        let(:end_time) { past }

        describe '.in_progress?' do
          it 'is false' do
            AbsoluteChronologicable.should_not be_in_progress
          end
        end

        describe '.expired' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.expired.should include chronologicable
          end
        end

        describe '.started' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.started.should include chronologicable
          end
        end

        describe '.current' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.current.should_not include chronologicable
          end
        end

        describe '.in_progress' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.in_progress.should_not include chronologicable
          end
        end
      end

      context 'and ends now' do
        let(:end_time) { now }

        describe '.in_progress?' do
          it 'is false' do
            AbsoluteChronologicable.should_not be_in_progress
          end
        end

        describe '.expired' do
          it 'does include that chronologicable' do
            AbsoluteChronologicable.expired.should include chronologicable
          end
        end

        describe '.started' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.started.should include chronologicable
          end
        end

        describe '.current' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.current.should_not include chronologicable
          end
        end

        describe '.in_progress' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.in_progress.should_not include chronologicable
          end
        end
      end

      context 'and ends later' do
        let(:end_time) { later }

        describe '.in_progress?' do
          it 'is true' do
            AbsoluteChronologicable.should be_in_progress
          end
        end

        describe '.expired' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.expired.should_not include chronologicable
          end
        end

        describe '.started' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.started.should include chronologicable
          end
        end

        describe '.current' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.current.should include chronologicable
          end
        end

        describe '.in_progress' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.in_progress.should include chronologicable
          end
        end
      end
    end

    context 'when there is a chronologicable that starts now' do
      let(:start_time) { now }

      context 'and ends now' do
        let(:end_time) { now }

        describe '.in_progress?' do
          it 'is false' do
            AbsoluteChronologicable.should_not be_in_progress
          end
        end

        describe '.expired' do
          it 'does include that chronologicable' do
            AbsoluteChronologicable.expired.should include chronologicable
          end
        end

        describe '.started' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.started.should include chronologicable
          end
        end

        describe '.current' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.current.should_not include chronologicable
          end
        end

        describe '.in_progress' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.in_progress.should_not include chronologicable
          end
        end
      end

      context 'and ends later' do
        let(:end_time) { later }

        describe '.in_progress?' do
          it 'is true' do
            AbsoluteChronologicable.should be_in_progress
          end
        end

        describe '.expired' do
          it 'does not include that chronologicable' do
            AbsoluteChronologicable.expired.should_not include chronologicable
          end
        end

        describe '.started' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.started.should include chronologicable
          end
        end

        describe '.current' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.current.should include chronologicable
          end
        end

        describe '.in_progress' do
          it 'includes that chronologicable' do
            AbsoluteChronologicable.in_progress.should include chronologicable
          end
        end
      end
    end

    context 'when there is a chronologicable that has not yet started' do
      let(:start_time) { later }
      let(:end_time)   { later }

      describe '.in_progress?' do
        it 'is false' do
          AbsoluteChronologicable.should_not be_in_progress
        end
      end

      describe '.expired' do
        it 'does not include that chronologicable' do
          AbsoluteChronologicable.expired.should_not include chronologicable
        end
      end

      describe '.started' do
        it 'does not include that chronologicable' do
          AbsoluteChronologicable.started.should_not include chronologicable
        end
      end

      describe '.current' do
        it 'includes that chronologicable' do
          AbsoluteChronologicable.current.should include chronologicable
        end
      end

      describe '.in_progress' do
        it 'does not include that chronologicable' do
          AbsoluteChronologicable.in_progress.should_not include chronologicable
        end
      end
    end
  end
end