require 'liquid/ext/enumerable'

describe Enumerable do

  it "should support the sum for a list of numbers" do
    [1,2,3,4,5].sum.should == 15
  end

  it "should support the mean for a list of numbers" do
    [1,2,3,4,5].mean.should == 3.0
  end

  it "should support the variance for a list of numbers" do
    [9,8,7,6,5].variance.should == 2.5
  end

  it "should support the standard deviation for a list of numbers" do
    [9,8,7,6,5].stdev.should == 1.5811388300841898
  end

  it "should support a percentile method for a list of numbers" do
    [9,1,8,2,7,3,6,4,5,4,3,2,1].percentile(0.9).should == 8
  end

end
