# frozen_string_literal: true
# rbs_inline: enabled

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    module Definitions
      # This enhancement handles resolving the superclass method and allows ruby-lsp to jump to the superclass definition
      class HandleSuperclass
        # @rbs!
        #   interface _ResponseBuilder
        #     def <<: (untyped) -> void
        #
        #     def response: -> Array[untyped]
        #   end

        # @rbs @index: untyped
        # @rbs @node: Prism::CallNode | Prism::ConstantPathNode
        # @rbs @nesting: Array[String]
        # @rbs @response_builder: _ResponseBuilder

        include Requests::Support::Common

        #: (Prism::CallNode | Prism::ConstantPathNode, Array[String], _ResponseBuilder, untyped) -> void
        def initialize(node, nesting, response_builder, index)
          @index = index
          @node = node

          # The value of the nesting variable are the namespaces that makes up the class
          #
          # Example:
          # ```
          # class Bar < Foo
          #   class BarInstance < superclass::FooInstance
          #     class CarInstance < superclass::OmegaInstance
          #     end
          #   end
          # end
          # ```
          #
          # In the example, when this class is initialized at `FooInstance` node, the value of nesting will be:
          # ['Bar', 'BarInstance', 'CarInstance']
          @nesting = nesting

          @response_builder = response_builder
        end

        #: () -> void
        def call
          # local variable helps with type narrowing
          node = @node

          case node
          when Prism::ConstantPathNode
            handle_superclass_node("superclass::#{node.name}", @nesting)
          when Prism::CallNode
            handle_superclass_node("superclass", @nesting)
          end
        end

        #: (String, Array[String]) -> void
        def handle_superclass_node(node_name, nesting)
          superclass_name = resolve_superclass_node(node_name, nesting)
          return if superclass_name.empty?

          superclass_entry = find_entry(superclass_name)

          (@response_builder << build_location_link(superclass_entry)) if superclass_entry
        end

        private

        #: (String, Array[String]) -> String
        def resolve_superclass_node(node_name, nesting)
          return node_name unless node_name.include?('superclass')

          parent_entry = find_entry(nesting[0..-2]&.join('::'))
          parent_entry_parent_class = parent_entry&.parent_class

          return '' if parent_entry.nil? || parent_entry_parent_class.nil?

          resolve_superclass_node(parent_entry_parent_class, parent_entry.nesting) + node_name.delete_prefix('superclass')
        end

        #: (RubyIndexer::Entry::Class entry_class) -> untyped
        def build_location_link(entry_class)
          location_params = {
            target_uri: URI::Generic.from_path(path: entry_class.file_path).to_s,
            target_range: range_from_location(entry_class.location),
            target_selection_range: range_from_location(entry_class.name_location),
          }

          Interface::LocationLink.new(**location_params)
        end

        #: (String? name, ?Array[String] nesting) -> RubyIndexer::Entry::Class?
        def find_entry(name, nesting = [])
          search(name || '', nesting).first
        end

        #: (String name, ?Array[String] nesting) -> Array[RubyIndexer::Entry::Class | untyped]
        def search(name, nesting = [])
          @index.resolve(name, nesting) || []
        end
      end
    end
  end
end
