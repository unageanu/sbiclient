
require 'rubygems'
require 'spec/rake/spectask'

desc "run tests.(without trade.)" 
Spec::Rake::SpecTask.new do |t|
  t.libs = ["./lib"]
  t.spec_files = FileList['spec/*_spec.rb']
end

desc "run all tests.(!! trade !!)" 
Spec::Rake::SpecTask.new(:spec_all) do |t|
  t.libs = ["./lib"]
  t.spec_files = FileList['spec/*_spec.rb', 'spec/*_spec!.rb']
end
