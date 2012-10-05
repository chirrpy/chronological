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
