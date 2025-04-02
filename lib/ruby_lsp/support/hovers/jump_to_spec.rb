# frozen_string_literal: true
# rbs_inline: enabled

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    module Hovers
      # An existing issue (https://github.com/Shopify/ruby-lsp/issues/2665) is available in the ruby-lsp repository.
      # We can remove this feature as soon as ruby-lsp supports it natively.
      class JumpToSpec
        # @rbs @node: Prism::ConstantPathNode | Prism::ConstantReadNode
        # @rbs @response_builder: untyped
        # @rbs @node_context: RubyLsp::NodeContext
        # @rbs @index: RubyLsp::Support::Decorators::IndexDecorator
        # @rbs @workspace_path: String
        # @rbs @spec_files: Array[String]

        include Requests::Support::Common

        #: (Prism::ConstantPathNode | Prism::ConstantReadNode, untyped, NodeContext, RubyIndexer::Index, String) -> void
        def initialize(node, response_builder, node_context, index, workspace_path)
          @node = node
          @response_builder = response_builder
          @node_context = node_context
          @workspace_path = workspace_path
          @index = RubyLsp::Support::Decorators::IndexDecorator.new(index)
        end

        #: () -> void
        def call
          index_entry = entry(@node)
          return if index_entry.nil?

          source = source_file(index_entry)
          return if source.empty?

          @response_builder.push("\n**Spec file:** #{source}", category: :links)
        end

        private

        #: (String, Array[String]) -> String
        def resolve_superclass_node(node_name, nesting)
          return node_name unless node_name.include?('superclass')

          parent_entry = @index.find_entry(nesting[0..-2]&.join('::'))
          parent_entry_parent_class = parent_entry&.parent_class

          return '' if parent_entry.nil? || parent_entry_parent_class.nil?

          resolve_superclass_node(parent_entry_parent_class, parent_entry.nesting) + node_name.delete_prefix('superclass')
        end

        #: (RubyIndexer::Entry::Namespace) -> ("" | ::String)
        def source_file(entry)
          file = find_spec_entry(entry)
          return "" if file.nil?

          absolute_filename = File.join(@workspace_path, file)
          filename = File.basename(file)

          "[#{filename}](#{absolute_filename})"
        end

        # Basically, searches files for the following patterns
        # - `describe Some::Class::Name `
        # - `describe Some::Class::Name,`
        # - `describe Some::Class::Name\n`
        # - `describe(Some::Class::Name)`
        #
        #: (RubyIndexer::Entry::Namespace) -> String?
        def find_spec_entry(entry)
          search_query = /describe(\(|\s)#{entry.name}(\s|\n|,|\))/

          # guess the spec filename based on the file path
          guessed_spec_file = get_guessed_spec_file(entry.file_path)
          return guessed_spec_file if File.file?(guessed_spec_file) && File.foreach(guessed_spec_file).grep(search_query).any?

          spec_files.find do |f|
            File.foreach(f).grep(search_query)[0]
          end
        end

        #: () -> Array[String]
        def spec_files
          @spec_files ||= Dir.glob("spec/**/*_spec.rb")
        end

        #: (Prism::ConstantPathNode | Prism::ConstantReadNode) -> String
        def full_name(node)
          node.slice.include?('superclass') ? resolve_superclass_node(node.slice, @node_context.nesting) : node.slice
        end

        #: (Prism::ConstantPathNode | Prism::ConstantReadNode node) -> RubyIndexer::Entry::Namespace?
        def entry(node)
          node_full_name = full_name(node)

          @index.search(node_full_name, @node_context.nesting).find do |e|
            e.is_a?(::RubyIndexer::Entry::Namespace)
          end
        end

        #: (String) -> String
        def get_guessed_spec_file(file_path)
          pathname = Pathname.new(file_path)

          guessed_relative_path = pathname.relative_path_from(@workspace_path).parent
          guessed_file_name = pathname.basename.sub(/\.rb$/, "_spec.rb")

          File.join('spec', guessed_relative_path.to_s, guessed_file_name.to_s)
        end
      end
    end
  end
end
