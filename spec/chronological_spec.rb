require 'spec_helper'

class Chronologicable < ActiveRecord::Base
  include Chronological
end

describe Chronological do
  let(:later) { Time.utc(2012, 7, 26, 6, 0, 26) }
  let(:now)   { Time.utc(2012, 7, 26, 6, 0, 25) }
  let(:past)  { Time.utc(2012, 7, 26, 6, 0, 24) }

  before      { Timecop.freeze(now)             }

  let(:chronologicable) do
    Chronologicable.create(
      :started_at_utc => start_time,
      :ended_at_utc   => end_time)
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

      describe '#scheduled?' do
        it 'is false' do
          chronologicable.should_not be_scheduled
        end
      end

      describe '#partially_scheduled?' do
        it 'is true' do
          chronologicable.should     be_partially_scheduled
        end
      end
    end

    context 'and an end time is set' do
      let(:end_time) { Time.now }

      describe '#scheduled?' do
        it 'is true' do
          chronologicable.should     be_scheduled
        end
      end

      describe '#partially_scheduled?' do
        it 'is true' do
          chronologicable.should     be_partially_scheduled
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
          chronologicable.should     be_partially_scheduled
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
    end

    context 'and ends now' do
      let(:end_time) { now }

      describe '#in_progress?' do
        it 'is false' do
          chronologicable.should_not be_in_progress
        end
      end
    end

    context 'and ends later' do
      let(:end_time) { later }

      describe '#in_progress?' do
        it 'is true' do
          chronologicable.should     be_in_progress
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
    end

    context 'and ends later' do
      let(:end_time) { later }

      describe '#in_progress?' do
        it 'is true' do
          chronologicable.should     be_in_progress
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
  end
end
