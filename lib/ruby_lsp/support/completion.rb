# frozen_string_literal: true

require_relative 'decorators/index_decorator'

module RubyLsp
  module Support
    class Completion
      def initialize(response_builder, node_context, global_state, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @index = RubyLsp::Support::Decorators::IndexDecorator.new global_state.index

        dispatcher.register(self, :on_call_node_enter)
      end

      def on_call_node_enter(node)
        # guard clause to allow nodes written inside the block
        # also ensures that the method name is define_handle_for before executing
        return if @node_context&.call_node&.name != :define_handle_for

        block_parameter = first_block_param(@node_context)

        # Ensures that the variable we're processing is defined as the block param
        receiver = node.receiver
        return if receiver.is_a?(Prism::LocalVariableReadNode) && receiver.name != block_parameter&.name || receiver.nil?

        # Guessing the data type
        inferred_type = infer_type(@node_context, @index)
        return if inferred_type.nil?

        # blacklisting classes so it wouldn't appear in the completion
        # Unsure if we need to add more
        owners = %w[Kernel BasicObject Object PP::ObjectMixin ActiveSupport::Tryable]

        method_candidates = @index.method_completion_candidates(nil, inferred_type.name).select do |e|
          next if e.visibility != RubyIndexer::Entry::Visibility::PUBLIC

          # e.owner.name == entry.name
          !owners.include?(e.owner.name)
        end

        method_candidates.each do |indexer_entry|
          label_details = Interface::CompletionItemLabelDetails.new(
            description: indexer_entry.file_name,
            detail: indexer_entry.decorated_parameters,
          )

          @response_builder << Interface::CompletionItem.new(
            label_details:,
            # The method name available
            label: indexer_entry.name,
            filter_text: indexer_entry.name,

            # text_edit:
            kind: Constant::CompletionItemKind::METHOD,
            data: {
              owner_name: indexer_entry&.name,
              guessed_type: inferred_type,
            },
          )
        end
      end

      private

      def block_parameters(node_context)
        call_node_block = node_context.call_node&.block

        return [] if !call_node_block.is_a?(Prism::BlockNode)
        return [] if !call_node_block.parameters.is_a?(Prism::BlockParametersNode)
        return [] if !call_node_block.parameters.parameters.is_a?(Prism::ParametersNode)

        # BlockNode -> BlockParametersNode -> ParametersNode -> Array[RequiredParameterNode]
        call_node_block.parameters.parameters.requireds
      end

      def first_block_param(node_context)
        first_param = block_parameters(node_context).first

        first_param.is_a?(Prism::RequiredParameterNode) ? first_param : nil
      end

      # The method argument tells us which class the block parameter is instantiated from
      # CallNode -> ArgumentsNode -> Array[ConstantReadNode]
      def method_argument(node_context)
        return '' if node_context.call_node.nil?

        node_context.call_node.arguments&.arguments&.first&.slice || ''
      end

      # The inferred_type is the method argument of `define_handle_for`
      def infer_type(node_context, index)
        argument = node_context.call_node&.arguments&.arguments&.first

        return unless argument.is_a?(Prism::ConstantReadNode)

        entry = index.find_entry(argument.name.to_s, [])

        RubyLsp::TypeInferrer::GuessedType.new(entry.name) if entry
      end
    end
  end
end
