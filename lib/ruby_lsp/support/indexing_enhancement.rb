# frozen_string_literal: true

# rbs_inline: enabled

module RubyLsp
  module Support
    class IndexingEnhancement < RubyIndexer::Enhancement
      # @rbs @listener: untyped

      #: (Prism::CallNode) -> void
      def on_call_node_enter(node)
        return if @listener.current_owner.nil?
        return if %i[attribute attribute?].none?(node.name)

        method_params = add_method_params(node)
        return if method_params.nil?

        @listener.add_method(
          method_params[:method_name],
          method_params[:location],
          [], # Method Signatures available to invoke this method
        )
      end

      #: (Prism::CallNode) -> String?
      def build_method_name(node)
        n = argument_node(node)

        case n
        when Prism::SymbolNode
          n.value
        when Prism::StringNode
          n.content
        end
      end

      #: (Prism::CallNode) -> untyped
      def argument_node(node)
        node.arguments&.child_nodes&.first
      end

      #: (Prism::CallNode) -> Prism::Location?
      def build_location(node)
        argument_node(node)&.location
      end

      #: (Prism::CallNode) -> { method_name: String, location: Prism::Location }?
      def add_method_params(node)
        method_name = build_method_name(node)
        location = build_location(node)

        return if method_name.nil? || location.nil?

        {
          method_name:,
          location:,
        }
      end
    end
  end
end
