# frozen_string_literal: true

require_relative 'decorators/indexer_decorator'

module RubyLsp
  module Support
    class Completion
      def initialize(response_builder, node_context, global_state, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @index = RubyLsp::Support::Decorators::IndexerDecorator.new global_state.index
        @nesting = node_context.nesting
        @type_inferrer = global_state.type_inferrer

        dispatcher.register(self, :on_call_node_enter)
      end

      # TODO:
      # - Find the local variable from the block
      # - Make ruby-lsp aware of the local variable (index enhancements)
      # - Get the correct type
      #   - Need to implement index enchancement
      # - Assign the type to the local variable
      def on_call_node_enter(node)
        # guard clause to allow nodes written inside the block
        # also makes sure that the method name is define_handle_for
        return if @node_context&.call_node&.name != :define_handle_for

        data_type = @node_context.call_node.arguments.arguments[0].name.to_s

        # if data type can't be guessed, abort
        return if data_type.nil?

        # Gets the block parameter
        #
        # Example:
        # ```
        # define_handle_for(Abc) do |event|
        # end`
        # ```
        # The value will be `event`
        block_parameter = @node_context&.call_node&.block&.parameters&.parameters&.requireds&.first&.name

        # Making sure that the variable we're trying to complete is defined as the block param
        return if node&.receiver&.name != block_parameter

        # Guessing the data type
        entry = @index.find_entry(data_type, [])
        return if entry.nil?

        type = RubyLsp::TypeInferrer::GuessedType.new(entry.name)

        # @node_context.call_node.block.parameters.parameters.requireds.first.name returns block parameter = :event
        # node.receiver.name -- gets the local variable

        # if @node_context.call_node.name == :define_handler_for then
        #   you are typing inside block

        # @node_context.call_node.arguments.arguments[0].name -- :User

        # method_completion_candidates params
        # 1st param - method name. Can be blank which will return all possible methods
        # 2nd param - Receiver. 'Foo' is a receiver

        method_candidates = @index.method_completion_candidates(nil, type.name).select do |e|
          next if e.visibility != RubyIndexer::Entry::Visibility::PUBLIC

          e.owner.name == entry.name
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
              guessed_type: type,
            },
          )
        end
      end
    end
  end
end
