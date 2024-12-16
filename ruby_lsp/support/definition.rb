# frozen_string_literal: true

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    class Definition
      def initialize(response_builder, node_context, index, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @index = index
        @nesting = node_context.nesting

        dispatcher.register(self, :on_call_node_enter, :on_constant_path_node_enter)
      end

      def on_call_node_enter(node)
        return if node.name != :superclass

        Definitions::HandleSuperclass.new(node, @nesting, @response_builder, @index).call
      end

      def on_constant_path_node_enter(node)
        parent_node = node.parent

        return unless parent_node.instance_of?(Prism::CallNode)
        return if parent_node.name != :superclass

        Definitions::HandleSuperclass.new(node, @nesting, @response_builder, @index).call
      end
    end
  end
end
