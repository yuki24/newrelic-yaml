require 'new_relic/agent/method_tracer'

DependencyDetection.defer do
  @name = :yaml

  module YamlInstrumentation
    def load(*)
      self.class.trace_execution_scoped('Serializer/Yaml/load'){ super }
    end

    def dump(*)
      self.class.trace_execution_scoped('Serializer/Yaml/dump'){ super }
    end
  end

  depends_on do
    defined?(::YAML) && YAML.respond_to?(:load) && YAML.respond_to?(:dump)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing YAML Instrumentation'
  end

  executes do
    class << YAML
      prepend YamlInstrumentation
    end
  end
end
