# frozen_string_literal: true

notification :terminal_notifier

rspec_options = {
  all_after_pass: true,
  cmd: 'rspec spec',
  failed_mode: :focus,
}

clearing :on

guard :rspec, rspec_options do
  require 'ostruct'

  # Generic Ruby apps
  rspec = OpenStruct.new
  rspec.spec = ->(m) { "spec/#{m}_spec.rb" }
  rspec.spec_dir = 'spec'
  rspec.spec_helper = 'spec/spec_helper.rb'

  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(rspec.spec_helper)      { rspec.spec_dir }
end

guard :rubocop, all_on_start: true do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end
