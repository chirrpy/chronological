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
end
