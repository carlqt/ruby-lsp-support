# frozen_string_literal: true

module RubyLsp # rubocop:disable Support/NamespacedDomain
  module Support
    module Hovers
      # An existing issue (https://github.com/Shopify/ruby-lsp/issues/2665) is available in the ruby-lsp repository.
      # We can remove this feature as soon as ruby-lsp supports it natively.
      class JumpToSpec
        include Requests::Support::Common

        def initialize(node, response_builder, node_context, index, workspace_path)
          @node = node
          @response_builder = response_builder
          @node_context = node_context
          @workspace_path = workspace_path
          @index = index
        end

        def call
          index_entry = entry(@node)
          return if index_entry.nil?

          source = source_file(index_entry)
          return if source.empty?

          @response_builder.push("\n**Spec file:** #{source}", category: :links)
        end

        private

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
        def find_spec_entry(entry)
          search_query = /describe(\(|\s)#{entry.name}(\s|\n|,|\))/

          # guess the spec filename based on the file path
          guessed_spec_file = get_guessed_spec_file(entry.file_path)
          return guessed_spec_file if File.file?(guessed_spec_file) && File.foreach(guessed_spec_file).grep(search_query).any?

          spec_files.find do |f|
            File.foreach(f).grep(search_query)[0]
          end
        end

        def spec_files
          @spec_files ||= Dir.glob("spec/**/*_spec.rb")
        end

        def full_name(constant_read_node)
          nesting = @node_context.nesting

          nesting.any? ? "#{nesting.join("::")}::#{constant_read_node.full_name}" : constant_read_node.full_name
        end

        def entry(node)
          node_full_name = case node
                           when Prism::ConstantPathNode
                             node.full_name
                           when Prism::ConstantReadNode
                             full_name(node)
                           end

          @index.resolve(node_full_name, @node_context.nesting).to_a.find do |e|
            e.is_a?(::RubyIndexer::Entry::Namespace)
          end # : RubyIndexer::Entry::Namespace? # rubocop:disable Style/CommentedKeyword,Lint/RedundantCopDisableDirective
        end

        def get_guessed_spec_file(file_path)
          pathname = Pathname.new(file_path)

          guessed_relative_path = pathname.relative_path_from(@workspace_path).parent
          guessed_file_name = pathname.basename.sub(/\.rb$/, "_spec.rb")

          File.join('spec', guessed_relative_path, guessed_file_name)
        end
      end
    end
  end
end
