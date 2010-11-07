Gem::Specification.new do |spec|
  spec.name = "sbiclient"
  spec.version = "0.1.5"
  spec.summary = "SBI securities client library for ruby."
  spec.author = "Masaya Yamauchi"
  spec.email = "y-masaya@red.hot.co.jp"
  spec.homepage = "http://github.com/unageanu/sbiclient/tree/master"
  spec.test_files =Dir.glob( "sample/*" ) + Dir.glob( "spec/*" )
  spec.files = [
    "README",
    "ChangeLog"
  ]+Dir.glob( "lib/*" )+spec.test_files
  spec.has_rdoc = true
  spec.rdoc_options << "--main" << "README"
  spec.add_dependency('mechanize', '>= 1.0.0')
  spec.extra_rdoc_files = ["README"]
end
