# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'uuidv47'
  spec.version       = '0.1.0'
  spec.authors       = ['Yuhei Nakasaka']
  spec.email         = ['yuhei.nakasaka@gmail.com']

  spec.summary       = 'UUIDv7-in/UUIDv4-out (SipHash-masked timestamp)'
  spec.description   = 'Ruby implementation of UUIDv47 - store sortable UUIDv7 in your database while emitting a UUIDv4-looking facade at your API boundary'
  spec.homepage      = 'https://github.com/YuheiNakasaka/uuidv47-rb'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
