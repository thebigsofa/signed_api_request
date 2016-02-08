# encoding: utf-8

require 'minitest/autorun'
require 'minitest/reporters'

require 'timecop'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
