require 'spec_helper'

class BaseChronologicable < ActiveRecord::Base
  extend Chronological::Base

  base_timeframe :starting_date => :started_on,
                 :starting_time => :started_at,
                 :ending_date   => :ended_on,
                 :ending_time   => :ended_at

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
