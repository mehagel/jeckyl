require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'jeckyl/errors'
require File.expand_path(File.dirname(__FILE__) + '/../test/test_configurator')

conf_path = File.expand_path(File.dirname(__FILE__) + '/../test/conf.d')

describe "Jeckyl" do

  # general tests

  it "should create a simple config" do
    #TestJeckyl.debug(true)
    conf_file = conf_path + '/jeckyl'
    conf = TestJeckyl.new(conf_file)
    conf[:log_dir].should match(/test$/)
    conf[:log_level].should == :verbose
    conf[:log_rotation].should == 5
    conf[:email].should == "robert@osburn-sharp.ath.cx"
    conf.has_key?(:sieve).should be_true
  end

  it "should be easy to set simple defaults" do
    conf_file = conf_path + '/jeckyl'
    defaults = {:master_key => 'ABCDEF'}
    conf = TestJeckyl.new(conf_file, defaults)
    conf[:master_key].should == 'ABCDEF'
  end

  # general exceptions

  it "should fail if the config file does not exist" do
    conf_file = conf_path + "/never/likely/to/be/there"
    lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigFileMissing, conf_file)
  end

  it "should raise an exception if a file parameter does not exist" do
    conf_file = conf_path + '/bad_filename'
    lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[log_dir\]:/)
  end

  it "should raise an exception if there is a syntax error" do
    conf_file = conf_path + '/syntax_error'
    lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigSyntaxError)
  end

  it "should raise an exception if there is an unknown parameter used" do
    conf_file = conf_path + '/unknown_param'
    lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::UnknownParameter)
  end

  # test parameters

  describe "File Parameters" do

    it "should raise an exception if a dir is not writable" do
      conf_file = conf_path + '/unwritable_dir'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[log_dir\]:/)
    end

    it "should raise an exception if file is not readable" do
      conf_file = conf_path + '/no_such_file'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[key_file\]:/)
    end

  end

  describe "Numeric Parameters" do

    it "should raise an exception if it gets a float when expecting an integer" do
      conf_file = conf_path + '/wrong_type'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[log_rotation\]:.*value is not of required type: Integer$/)
    end

    it "should raise an exception if it gets a number out of range" do
      conf_file = conf_path + '/out_of_range'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[log_rotation\]:.*value is not within required range: 0..20$/)
    end

    it "should raise an exception if it gets an integer instead of a float" do
      conf_file = conf_path + '/not_a_float'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[pi\]:.*value is not of required type: Float$/)
    end

  end

  describe "Boolean Parameters" do

    it "should raise an exception if it gets a string instead of a boolean" do
      conf_file = conf_path + '/not_a_bool'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[debug\]:.*Value is not a Boolean$/)
    end

    it "should raise an exception if it gets an invalid flag value" do
      conf_file = conf_path + '/not_a_flag'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[flag\]:.*Cannot convert to Boolean$/)
    end

  end

  describe "Compound Parameters" do

    it "should raise an exception if it gets a string instead of an array" do
      conf_file = conf_path + '/not_an_array'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[collection\]:.*value is not an Array$/)
    end

    it "should raise an exception if it gets a string instead of a hash" do
      conf_file = conf_path + '/not_a_hash'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[options\]:.*value is not a Hash$/)
    end

    it "should raise an exception if it gets an array of strings instead of a integers" do
      conf_file = conf_path + '/not_an_integer_array'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[sieve\]:.*element of array is not of type: Integer$/)
    end

  end

  describe "String Parameters" do

    it "should raise an exception if it gets a number instead of a string" do
      conf_file = conf_path + '/not_a_string'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[email\]:.*is not a String$/)
    end

    it "should raise an exception if a string does not match the required pattern" do
      conf_file = conf_path + '/not_an_email'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[email\]:.*does not match required pattern:/)
    end

    it "should raise an exception if it gets a patter that is not a pattern" do
      conf_file = conf_path + '/not_a_pattern'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigSyntaxError, "Attempt to pattern match without a Regexp")
    end

  end

  describe "Set Parameters" do

    it "should raise an exception if it gets a set that is not an array" do
      conf_file = conf_path + '/not_a_set'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigSyntaxError, "Sets to test membership must be arrays")
    end

    it "should raise an exception if a value is not in the given set" do
      conf_file = conf_path + '/not_a_member'
      lambda{conf = TestJeckyl.new(conf_file)}.should raise_error(Jeckyl::ConfigError, /^\[log_level\]:.*is not a member of:/)
    end


  end

  describe "Operating in a more relaxed mode" do

    # leave at the end or you need to re-strict Jeckyl.
    it "should load any parameter if its not being strict" do
      conf_file = conf_path + '/sloppy_params'
      TestJeckyl.relax
      conf = TestJeckyl.new(conf_file)
      conf[:my_age].should == 50
    end

  end

end
