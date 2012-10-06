require 'spec_helper'

class Chronologicable < ActiveRecord::Base
  include Chronological

  chronological :start_utc => :started_at_utc,
                :end_utc   => :ended_at_utc
end

class ChronologicableWithTimeZone < ActiveRecord::Base
  include Chronological

  chronological :start_utc => :started_at_utc,
                :end_utc   => :ended_at_utc,
                :time_zone => :time_zone
end

describe Chronological, :timecop => true do
  let(:later) { Time.local(2012, 7, 26, 6, 0, 26) }
  let(:now)   { Time.local(2012, 7, 26, 6, 0, 25) }
  let(:past)  { Time.local(2012, 7, 26, 6, 0, 24) }

  before      { Timecop.freeze(now)             }

  let(:chronologicable) do
    Chronologicable.create(
      :started_at_utc => start_time,
      :ended_at_utc   => end_time)
  end

  let(:chronologicable_without_enabled_time_zone) do
    Chronologicable.new(
      :started_at_utc => start_time,
      :ended_at_utc   => end_time)
  end

  let(:chronologicable_with_enabled_time_zone) do
    ChronologicableWithTimeZone.new(
      :started_at_utc => start_time,
      :ended_at_utc   => end_time,
      :time_zone      => time_zone)
  end

  it { Chronologicable.new.respond_to?(:starts_at_utc).should   be_true }
  it { Chronologicable.new.respond_to?(:starting_at_utc).should be_true }
  it { Chronologicable.new.respond_to?(:ends_at_utc).should     be_true }
  it { Chronologicable.new.respond_to?(:ending_at_utc).should   be_true }
  it { Chronologicable.new.respond_to?(:active?).should         be_true }

  it { Chronologicable.respond_to?(:active?).should             be_true }
  it { Chronologicable.respond_to?(:active).should              be_true }

  context 'when there are two chronologicables that start at the same time' do
    context 'but end at different times' do
      let!(:chronologicable_1) { Chronologicable.create :started_at_utc => past, :ended_at_utc => past }
      let!(:chronologicable_2) { Chronologicable.create :started_at_utc => past, :ended_at_utc => now }

      describe '.by_date' do
        it 'properly sorts them' do
          Chronologicable.by_date.first.should  eql chronologicable_1
          Chronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          Chronologicable.by_date_reversed.first.should  eql chronologicable_2
          Chronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end

    context 'and end at the same time' do
      let!(:chronologicable_1) { Chronologicable.create :started_at_utc => past, :ended_at_utc => now }
      let!(:chronologicable_2) { Chronologicable.create :started_at_utc => past, :ended_at_utc => now }

      describe '.by_date' do
        it 'does not matter what order they are in as long as they are all there' do
          Chronologicable.by_date.should  include chronologicable_1
          Chronologicable.by_date.should  include chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'does not matter what order they are in as long as they are all there' do
          Chronologicable.by_date.should  include chronologicable_1
          Chronologicable.by_date.should  include chronologicable_2
        end
      end
    end
  end

  context 'when there are two chronologicables that start at different times' do
    context 'and end at different times' do
      let!(:chronologicable_1) { Chronologicable.create :started_at_utc => past, :ended_at_utc => now }
      let!(:chronologicable_2) { Chronologicable.create :started_at_utc => now,  :ended_at_utc => later }

      describe '.by_date' do
        it 'sorts them by the start date' do
          Chronologicable.by_date.first.should  eql chronologicable_1
          Chronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          Chronologicable.by_date_reversed.first.should  eql chronologicable_2
          Chronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end

    context 'but end at the same time' do
      let!(:chronologicable_1) { Chronologicable.create :started_at_utc => past, :ended_at_utc => later }
      let!(:chronologicable_2) { Chronologicable.create :started_at_utc => now,  :ended_at_utc => later }

      describe '.by_date' do
        it 'sorts them by the start date' do
          Chronologicable.by_date.first.should  eql chronologicable_1
          Chronologicable.by_date.last.should   eql chronologicable_2
        end
      end

      describe '.by_date_reversed' do
        it 'sorts them backwards by the start date' do
          Chronologicable.by_date_reversed.first.should  eql chronologicable_2
          Chronologicable.by_date_reversed.last.should   eql chronologicable_1
        end
      end
    end
  end

  describe '#started_at_utc_date' do
    context 'when the date field is set to a string' do
      let(:start_time) { '2012-07-26 03:15:12' }
      let(:end_time)   { nil }

      it 'properly converts the date' do
        chronologicable.started_at_utc_date.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end

    context 'when the date field is set to a date' do
      let(:start_time) { Time.utc(2012, 7, 26, 3, 15, 12) }
      let(:end_time)   { nil }

      it 'properly converts the date' do
        chronologicable.started_at_utc_date.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end
  end

  describe '#ended_at_utc_date' do
    context 'when the date field is set to a string' do
      let(:start_time)  { nil }
      let(:end_time)    { '2012-07-26 03:15:12' }

      it 'properly converts the date' do
        chronologicable.ended_at_utc_date.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end

    context 'when the date field is set to a date' do
      let(:start_time)  { nil }
      let(:end_time)    { Time.utc(2012, 7, 26, 3, 15, 12) }

      it 'properly converts the date' do
        chronologicable.ended_at_utc_date.should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end
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

      describe '#in_progress?' do
        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      describe '.in_progress?' do
        it 'is false' do
          chronologicable
          Chronologicable.should_not be_in_progress
        end
      end

      describe '.expired' do
        it 'includes that chronologicable' do
          Chronologicable.expired.should include chronologicable
        end
      end

      describe '.started' do
        it 'includes that chronologicable' do
          Chronologicable.started.should include chronologicable
        end
      end

      describe '.current' do
        it 'does not include that chronologicable' do
          Chronologicable.current.should_not include chronologicable
        end
      end

      describe '.in_progress' do
        it 'does not include that chronologicable' do
          Chronologicable.in_progress.should_not include chronologicable
        end
      end
    end

    context 'and ends now' do
      let(:end_time) { now }

      describe '#in_progress?' do
        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      describe '.in_progress?' do
        it 'is false' do
          chronologicable
          Chronologicable.should_not be_in_progress
        end
      end

      describe '.expired' do
        it 'does include that chronologicable' do
          Chronologicable.expired.should include chronologicable
        end
      end

      describe '.started' do
        it 'includes that chronologicable' do
          Chronologicable.started.should include chronologicable
        end
      end

      describe '.current' do
        it 'does not include that chronologicable' do
          Chronologicable.current.should_not include chronologicable
        end
      end

      describe '.in_progress' do
        it 'does not include that chronologicable' do
          Chronologicable.in_progress.should_not include chronologicable
        end
      end
    end

    context 'and ends later' do
      let(:end_time) { later }

      describe '#in_progress?' do
        it 'is true' do
          chronologicable.should be_in_progress
        end
      end

      describe '.in_progress?' do
        it 'is true' do
          chronologicable
          Chronologicable.should be_in_progress
        end
      end

      describe '.expired' do
        it 'does not include that chronologicable' do
          Chronologicable.expired.should_not include chronologicable
        end
      end

      describe '.started' do
        it 'includes that chronologicable' do
          Chronologicable.started.should include chronologicable
        end
      end

      describe '.current' do
        it 'includes that chronologicable' do
          Chronologicable.current.should include chronologicable
        end
      end

      describe '.in_progress' do
        it 'includes that chronologicable' do
          Chronologicable.in_progress.should include chronologicable
        end
      end
    end
  end

  context 'when there is a chronologicable that starts now' do
    let(:start_time) { now }

    context 'and ends now' do
      let(:end_time) { now }

      describe '#in_progress?' do
        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end

      describe '.in_progress?' do
        it 'is false' do
          chronologicable
          Chronologicable.should_not be_in_progress
        end
      end

      describe '.expired' do
        it 'does include that chronologicable' do
          Chronologicable.expired.should include chronologicable
        end
      end

      describe '.started' do
        it 'includes that chronologicable' do
          Chronologicable.started.should include chronologicable
        end
      end

      describe '.current' do
        it 'does not include that chronologicable' do
          Chronologicable.current.should_not include chronologicable
        end
      end

      describe '.in_progress' do
        it 'does not include that chronologicable' do
          Chronologicable.in_progress.should_not include chronologicable
        end
      end
    end

    context 'and ends later' do
      let(:end_time) { later }

      describe '#in_progress?' do
        it 'is true' do
          chronologicable.should be_in_progress
        end
      end

      describe '.in_progress?' do
        it 'is true' do
          chronologicable
          Chronologicable.should be_in_progress
        end
      end

      describe '.expired' do
        it 'does not include that chronologicable' do
          Chronologicable.expired.should_not include chronologicable
        end
      end

      describe '.started' do
        it 'includes that chronologicable' do
          Chronologicable.started.should include chronologicable
        end
      end

      describe '.current' do
        it 'includes that chronologicable' do
          Chronologicable.current.should include chronologicable
        end
      end

      describe '.in_progress' do
        it 'includes that chronologicable' do
          Chronologicable.in_progress.should include chronologicable
        end
      end
    end
  end

  context 'when there is a chronologicable that has not yet started' do
    let(:start_time) { later }
    let(:end_time)   { later }

    describe '#in_progress?' do
      it 'is false' do
        chronologicable.should_not be_in_progress
      end
    end

    describe '.in_progress?' do
      it 'is false' do
        chronologicable
        Chronologicable.should_not be_in_progress
      end
    end

    describe '.expired' do
      it 'does not include that chronologicable' do
        Chronologicable.expired.should_not include chronologicable
      end
    end

    describe '.started' do
      it 'does not include that chronologicable' do
        Chronologicable.started.should_not include chronologicable
      end
    end

    describe '.current' do
      it 'includes that chronologicable' do
        Chronologicable.current.should include chronologicable
      end
    end

    describe '.in_progress' do
      it 'does not include that chronologicable' do
        Chronologicable.in_progress.should_not include chronologicable
      end
    end
  end

  describe '#duration' do
    context 'when the chronologicable represents something with a complex time duration' do
      let(:start_time) { Time.local(2012, 7, 26, 14, 13, 16) }
      let(:end_time)   { Time.local(2012, 7, 26, 15, 57, 39) }

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
      let(:start_time) { Time.local(2012, 7, 26, 14, 13, 16) }
      let(:end_time)   { Time.local(2012, 7, 26, 15, 57, 16) }

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
      let(:start_time) { Time.local(2012, 7, 26, 14, 13, 16) }
      let(:end_time)   { Time.local(2012, 7, 26, 15, 13, 16) }

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
      let(:start_time) { Time.local(2012, 7, 26, 14, 13, 16) }
      let(:end_time)   { Time.local(2012, 7, 26, 14, 13, 16) }

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
  end
end
