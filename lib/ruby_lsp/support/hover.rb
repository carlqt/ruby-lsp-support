# frozen_string_literal: true
# rbs_inline: enabled

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    class Hover
      # @rbs @response_builder: untyped
      # @rbs @node_context: RubyLsp::NodeContext
      # @rbs @index: RubyIndexer::Index
      # @rbs @workspace_path: String
      # @rbs @global_state: untyped

      include Requests::Support::Common

      #: (untyped, RubyLsp::NodeContext, untyped, untyped) -> void
      def initialize(response_builder, node_context, dispatcher, global_state)
        @response_builder = response_builder
        @node_context = node_context
        @index = global_state.index
        @workspace_path = global_state.workspace_path
        @global_state = global_state

        dispatcher.register(self, :on_constant_path_node_enter, :on_constant_read_node_enter)
      end

      #: (Prism::ConstantReadNode node) -> void
      def on_constant_read_node_enter(node)
        Hovers::JumpToSpec.new(node, @response_builder, @node_context, @index, @workspace_path).call
      end

      #: (Prism::ConstantPathNode node) -> void
      def on_constant_path_node_enter(node)
        Hovers::JumpToSpec.new(node, @response_builder, @node_context, @index, @workspace_path).call
      end
    end
  end
end
