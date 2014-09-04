require 'spec_helper'

if Object.const_defined?(:ActiveModel) && ActiveModel::VERSION::STRING < "4.1.0"

  require 'test/unit'
  require 'test/unit/assertions'
  require 'active_model/lint'

  describe ActiveModel::Lint do
    include Test::Unit::Assertions
    include ActiveModel::Lint::Tests

    before do
      class Category < ActiveHash::Base
      end
    end

    after do
      Object.send(:remove_const, :Category)
    end

    # to_s is to support ruby-1.9
    ActiveModel::Lint::Tests.public_instance_methods.map { |m| m.to_s }.grep(/^test/).each do |m|
      example m.gsub('_', ' ') do
        send m
      end
    end

    def model
      Category.new
    end

  end

end

