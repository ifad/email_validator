require 'rake'

spec = Gem::Specification.new do |s|
  s.name             = 'vjt-email_validator'
  s.version          = '1.5.2'
  s.summary          = 'Validate e-mail addresses against RFC 2822 and RFC 3696.'
  s.description      = 'ActiveModel::EachValidator to check for valid e-mail addresses'
  s.extra_rdoc_files = %w( README.rdoc CHANGELOG.rdoc MIT-LICENSE )
  s.test_files       = FileList['test/**/*.rb', 'test/**/*.yml'].to_a
  s.files            = FileList['MIT-LICENSE', '*.rb', '*.rdoc', 'lib/**/*.rb', 'test/**/*.rb', 'test/**/*.yml'].to_a
  s.require_path     = 'lib'
  s.has_rdoc         = true
  s.authors          = ['Marcello Barnaba', 'Alex Dunae']
  s.email            = 'vjt@openssl.it'
  s.homepage         = 'http://github.com/vjt/email_validator'

  s.rdoc_options << '--title' <<  'email_validator'
end
