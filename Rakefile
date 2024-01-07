# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rb_sys/extensiontask"
require "rubocop/rake_task"

task build: :compile

GEMSPEC = Gem::Specification.load("dolos.gemspec")

RbSys::ExtensionTask.new("dolos", GEMSPEC) do |ext|
  ext.lib_dir = "lib/dolos"
end

RuboCop::RakeTask.new

task default: %i[compile spec rubocop]
