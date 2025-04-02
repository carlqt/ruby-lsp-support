# frozen_string_literal: true
# rbs_inline: enabled

module RubyLsp
  module Support
    class Definition
      # @rbs @response_builder: untyped
      # @rbs @node_context: RubyLsp::NodeContext
      # @rbs @index: RubyIndexer::Index
      # @rbs @nesting: Array[String]

      #: (untyped, NodeContext, RubyIndexer::Index, untyped) -> void
      def initialize(response_builder, node_context, index, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @index = index
        @nesting = node_context.nesting

        dispatcher.register(self, :on_call_node_enter, :on_constant_path_node_enter)
      end

      #: (Prism::CallNode) -> void
      def on_call_node_enter(node)
        return if node.name != :superclass

        Definitions::HandleSuperclass.new(node, @node_context, @response_builder, @index).call
      end

      #: (Prism::ConstantPathNode) -> void
      def on_constant_path_node_enter(node)
        node.full_name

      rescue Prism::ConstantPathNode::DynamicPartsInConstantPathError
        return unless node.slice.include?('superclass')

        Definitions::HandleSuperclass.new(node, @node_context, @response_builder, @index).call
      end
    end
  end
end
