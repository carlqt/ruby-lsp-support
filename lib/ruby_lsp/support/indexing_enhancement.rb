# frozen_string_literal: true

# require 'debug/open'

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    class IndexingEnhancement < RubyIndexer::Enhancement

      def on_call_node_enter(node)
        owner = @listener.current_owner
        return unless owner
        return unless node.name == :attribute

        location = node.location

        signatures = [
          # RubyIndexer::Entry::Signature.new([RubyIndexer::Entry::RequiredParameter.new(name: :a)])
        ]

        method_name = node.arguments.arguments[0].unescaped
        @listener.add_method(
          method_name, # Name of the method
          location,     # Prism location for the node defining this method
          signatures    # Signatures available to invoke this method
        )
      end
    end
  end
end
