# -*- coding: utf-8 -*- 

require 'rubygems'
require 'rspec/core/rake_task'

desc "run tests.(without trade.)" 
RSpec::Core::RakeTask.new do |t|
  t.ruby_opts =  '-I ./lib -I ./spec'
  t.pattern = 'spec/*_spec.rb'
end

desc "run daily tests." 
RSpec::Core::RakeTask.new(:spec_daily) do |t|
  t.ruby_opts =  '-I ./lib -I ./spec'
  t.pattern = 'spec/jiji_plugin_daily_spec.rb'
end

desc "run all tests.(!! trade !!)" 
RSpec::Core::RakeTask.new(:spec_all) do |t|
  t.ruby_opts =  '-I ./lib -I ./spec'
  t.pattern = 'spec/*_spec*.rb'
end
