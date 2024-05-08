# frozen_string_literal: true

module Uinit
  module Memoizable
    VERSION = '0.1.0'

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def memo(method_sym)
        method = instance_method(method_sym)
        memo_var = memo_variable_name(method_sym)

        define_method(method_sym) do |*args, **kwargs|
          return instance_variable_get(memo_var) if instance_variable_defined?(memo_var)

          instance_variable_set(memo_var, method.bind_call(self, *args, **kwargs))
        end
      end

      def memo_self(method_sym)
        method = singleton_class.instance_method(method_sym)
        memo_var = memo_variable_name(method_sym)

        define_singleton_method(method_sym) do |*args, **kwargs|
          return singleton_class.instance_variable_get(memo_var) if singleton_class.instance_variable_defined?(memo_var)

          singleton_class.instance_variable_set(memo_var, method.bind_call(self, *args, **kwargs))
        end
      end

      def memo_unset(method_sym)
        memo_var = memo_variable_name(method_sym)

        return unless singleton_class.instance_variable_defined?(memo_var)

        singleton_class.remove_instance_variable(memo_var)
      end

      def memo_variable_name(method_sym)
        predicate = method_sym.to_s.end_with?('?')

        :"@#{predicate ? '__memois_' : '__memo_'}#{method_sym.to_s.tr('?', '_')}"
      end
    end

    def memo_unset(method_sym)
      memo_var = self.class.memo_variable_name(method_sym)

      return unless instance_variable_defined?(memo_var)

      remove_instance_variable(memo_var)
    end
  end
end
