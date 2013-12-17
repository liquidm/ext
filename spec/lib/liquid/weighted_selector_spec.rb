# encoding: utf-8

require 'liquid/weighted_selector'

describe WeightedSelector do

  describe "#empty?" do

    it do
      should be_empty
    end

    context do

      before do
        subject.add 'a', 0
      end

      it do
        should_not be_empty
      end

    end
  end

  describe '#pick_one' do

    context do

      before do
        subject.add 'a', 2
        subject.add 'b', 2
        subject.add 'c', 0
      end

      it do
        ['a', 'b'].should include subject.pick_one
      end

    end

    context do

      before do
        subject.add 'a', 2
        subject.add 'b', 2
        subject.add 'c', 0
        subject.delete 'a'
      end

      its(:pick_one){ should == 'b' }
      its(:pick_one_with_index){ should == ['b', 0] }

    end

    context do

      before do
        Kernel.stub(:rand).and_return(1.00)
        subject.add 'a', 0.1
      end

      its(:pick_one){ should == 'a' }

    end
  end
end
