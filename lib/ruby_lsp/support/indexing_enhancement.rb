# frozen_string_literal: true

# require 'debug/open'

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    class IndexingEnhancement < RubyIndexer::Enhancement

      def on_call_node_enter(node)
        owner = @listener.current_owner

        return if owner.nil?

        # Enhance if node.name is :attribute
        return unless node.name == :attribute

        # RubyIndexer::Entry::Signature.new([RubyIndexer::Entry::RequiredParameter.new(name: :a)])
        signatures = [] #: untyped

        argument_node = node.arguments&.child_nodes&.first

        # Taken from ruby-lsp-rails
        # Getting type error in logs if we don't check the types
        method_name = case argument_node
        when Prism::SymbolNode
          argument_node.value 
        when Prism::StringNode
          argument_node.content
        end

        return if argument_node.nil? || method_name.nil?

        @listener.add_method(
          method_name,

          argument_node.location, # Prism location for the node defining this method
          signatures # Signatures available to invoke this method
        )
      end
    end
  end
end
