require 'spec_helper'
require 'ostruct'

describe Chronological::BaseStrategy do
  let(:strategy)    { Chronological::BaseStrategy.new(field_names)  }
  let(:chrono)      { OpenStruct.new(fields)                        }
  let(:fields)      { nil                                           }
  let(:field_names) do
    { starting_time:  :start_time,
      ending_time:    :end_time }
  end

  describe '#starting_date' do
    context 'when working with a date/time' do
      let(:fields)  { { start_time:     Time.utc(2012, 7, 26, 7, 12, 0) } }

      it 'converts it to a date only' do
        strategy.starting_date(chrono).should eql Time.utc(2012, 7, 26, 7, 12, 0).to_date
      end
    end

    context 'when working with a string' do
      let(:fields) { { start_time:      '2012-07-26 03:15:12' } }

      it 'properly converts the date' do
        strategy.starting_date(chrono).should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end

    context 'when working with nothing' do
      let(:fields) { { start_time:      nil } }

      it 'is nil' do
        strategy.starting_date(chrono).should be_nil
      end
    end
  end

  describe '#ending_date' do
    context 'when working with a date/time' do
      let(:fields)  { { end_time:     Time.utc(2012, 7, 26, 7, 12, 0) } }

      it 'converts it to a date only' do
        strategy.ending_date(chrono).should eql Time.utc(2012, 7, 26, 7, 12, 0).to_date
      end
    end

    context 'when working with a string' do
      let(:fields) { { end_time:      '2012-07-26 03:15:12' } }

      it 'properly converts the date' do
        strategy.ending_date(chrono).should eql Time.utc(2012, 7, 26, 3, 15, 12).to_date
      end
    end

    context 'when working with nothing' do
      let(:fields) { { end_time:      nil } }

      it 'is nil' do
        strategy.ending_date(chrono).should be_nil
      end
    end
  end

  describe '#inactive?' do
    it 'is the opposite of in_progress?' do
      chrono.should_receive(:in_progress?).and_return false

      strategy.inactive?(chrono).should be_true
    end
  end

  describe '#duration' do
    context 'when the strategy represents something with a duration' do
      before { strategy.should_receive(:duration_in_seconds).and_return(6263) }

      it 'is a hash with the correct hours' do
        strategy.duration(chrono)[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        strategy.duration(chrono)[:minutes].should eql 44
      end

      it 'is a hash with the correct seconds' do
        strategy.duration(chrono)[:seconds].should eql 23
      end
    end

    context 'when the strategy represents something with an even second time duration' do
      before { strategy.should_receive(:duration_in_seconds).and_return(6240) }

      it 'is a hash with the correct hours' do
        strategy.duration(chrono)[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        strategy.duration(chrono)[:minutes].should eql 44
      end

      it 'is a hash with the correct seconds' do
        strategy.duration(chrono)[:seconds].should eql 0
      end
    end

    context 'when the strategy represents something with an even minute time duration' do
      before { strategy.should_receive(:duration_in_seconds).and_return(3600) }

      it 'is a hash with the correct hours' do
        strategy.duration(chrono)[:hours].should eql 1
      end

      it 'is a hash with the correct minutes' do
        strategy.duration(chrono)[:minutes].should eql 0
      end

      it 'is a hash with the correct seconds' do
        strategy.duration(chrono)[:seconds].should eql 0
      end
    end

    context 'when the strategy represents something with a zero duration' do
      before { strategy.should_receive(:duration_in_seconds).and_return(0) }

      it 'is a hash with the correct hours' do
        strategy.duration(chrono)[:hours].should eql 0
      end

      it 'is a hash with the correct minutes' do
        strategy.duration(chrono)[:minutes].should eql 0
      end

      it 'is a hash with the correct seconds' do
        strategy.duration(chrono)[:seconds].should eql 0
      end
    end

    context 'when duration in seconds returns an empty value' do
      before { strategy.should_receive(:duration_in_seconds).and_return(nil) }

      it 'is an empty hash' do
        strategy.duration(chrono).should eql Hash.new
      end
    end
  end

  describe '#in_progress?', :timecop => true do
    let(:later) { Time.local(2012, 7, 26, 6, 0, 26) }
    let(:now)   { Time.local(2012, 7, 26, 6, 0, 25) }
    let(:past)  { Time.local(2012, 7, 26, 6, 0, 24) }

    before      { Timecop.freeze(now)             }

    context 'when it does not have an absolute timeframe' do
      before { strategy.should_receive(:has_absolute_timeframe?).and_return(false) }

      it 'is false' do
        strategy.in_progress?(chrono).should_not be_true
      end
    end

    context 'when it does have an absolute timeframe' do
      before { strategy.should_receive(:has_absolute_timeframe?).and_return(true) }

      context 'and it has already started' do
        context 'and already ended' do
          let(:fields) do
            { start_time: past,
              end_time:   past }
          end

          it 'is false' do
            strategy.in_progress?(chrono).should_not be_true
          end
        end

        context 'and ends now' do
          let(:fields) do
            { start_time: past,
              end_time:   now }
          end

          it 'is false' do
            strategy.in_progress?(chrono).should_not be_true
          end
        end

        context 'and ends later' do
          let(:fields) do
            { start_time: past,
              end_time:   later }
          end

          it 'is true' do
            strategy.in_progress?(chrono).should be_true
          end
        end
      end

      context 'and there is a strategy that starts now' do
        context 'and ends now' do
          let(:fields) do
            { start_time: now,
              end_time:   now }
          end

          it 'is false' do
            strategy.in_progress?(chrono).should_not be_true
          end
        end

        context 'and ends later' do
          let(:fields) do
            { start_time: now,
              end_time:   later }
          end

          it 'is true' do
            strategy.in_progress?(chrono).should be_true
          end
        end
      end

      context 'and there is a strategy that has not yet started' do
        let(:fields) do
          { start_time: later,
            end_time:   later }
        end

        it 'is false' do
          strategy.in_progress?(chrono).should_not be_true
        end
      end
    end
  end

  describe '#scheduled?' do
    context 'when the time zone option is passed in' do
      let(:field_names) { { time_zone: :time_zone } }

      context 'and a time zone exists' do
        let(:fields) { { time_zone: 'Alaska' } }

        it 'is the time zone' do
          strategy.scheduled?(chrono).should eql 'Alaska'
        end
      end

      context 'and a time zone does not exist' do
        let(:fields) { { time_zone: nil } }

        it 'is the time zone' do
          strategy.scheduled?(chrono).should be_nil
        end
      end
    end

    context 'when the time zone option is not passed in' do
      let(:field_names) { Hash.new }

      it 'is always true' do
        strategy.scheduled?(chrono).should be_true
      end
    end
  end

  describe '#partially_scheduled?' do
    context 'when the time zone option is passed in' do
      let(:field_names) { { time_zone: :time_zone } }

      context 'and a time zone exists' do
        let(:fields) { { time_zone: 'Alaska' } }

        it 'is the time zone' do
          strategy.partially_scheduled?(chrono).should eql 'Alaska'
        end
      end

      context 'and a time zone does not exist' do
        let(:fields) { { time_zone: nil } }

        it 'is the time zone' do
          strategy.partially_scheduled?(chrono).should be_nil
        end
      end
    end

    context 'when the time zone option is not passed in' do
      let(:field_names) { Hash.new }

      it 'is always false' do
        strategy.partially_scheduled?(chrono).should be_false
      end
    end
  end
end
