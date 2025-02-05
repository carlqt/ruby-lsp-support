# frozen_string_literal: true

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    class Hover
      include Requests::Support::Common

      def initialize(response_builder, node_context, dispatcher, global_state)
        @response_builder = response_builder
        @node_context = node_context
        @index = global_state.index
        @workspace_path = global_state.workspace_path
        @global_state = global_state

        dispatcher.register(self, :on_constant_path_node_enter, :on_constant_read_node_enter)
      end

      def on_constant_read_node_enter(node)

        Hovers::JumpToSpec.new(node, @response_builder, @node_context, @index, @workspace_path).call
      end

      def on_constant_path_node_enter(node)
        Hovers::JumpToSpec.new(node, @response_builder, @node_context, @index, @workspace_path).call
      end
    end
  end
end
