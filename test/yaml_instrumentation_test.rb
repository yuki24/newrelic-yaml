require 'minitest/autorun'
require 'minitest/unit'

require 'new_relic/agent/instrumentation/yaml'

class YamlInstrumentationTest < Minitest::Test
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def setup
    NewRelic::Agent.manual_start
    @engine = NewRelic::Agent.instance.stats_engine
    @engine.clear_stats
  end

  def test_load
    hash = YAML.load("---\nhash:\n  1: one\n  2: two\n")

    assert_equal({"hash" => {1 => "one", 2 => "two"}}, hash)
    assert_metrics "Serializer/Yaml/load"
  end

  def test_dump
    yaml_data = YAML.dump("hash" => {1 => "one", 2 => "two"})

    assert_equal "---\nhash:\n  1: one\n  2: two\n", yaml_data
    assert_metrics "Serializer/Yaml/dump"
  end

  def test_ignore
    NewRelic::Agent.disable_all_tracing do
      YAML.load("---\nhash:\n  1: one\n  2: two\n")
    end

    assert_equal 0, @engine.metrics.size
  end

  private

  def assert_metrics(*m)
    m.each do |x|
      assert @engine.metrics.include?(x), "#{x} not in metrics"
    end
  end
end
