# frozen_string_literal: true

# rbs_inline: enabled

require_relative '../decorators/index_decorator'

module RubyLsp
  module Support
    module Completions
      class DefineHandlerFor
        # @rbs @response_builder: untyped
        # @rbs @node_context: RubyLsp::NodeContext
        # @rbs @index: RubyLsp::Support::Decorators::IndexDecorator

        COMPLETION_FOR_METHOD = :define_handler_for
        COMMON_ANCESTORS = %w[BasicObject Object Kernel].freeze #: ["BasicObject", "Object", "Kernel"]

        #: (untyped response_builder, RubyLsp::NodeContext node_context, untyped global_state, Prism::Dispatcher dispatcher) -> void
        def initialize(response_builder, node_context, global_state, dispatcher)
          @response_builder = response_builder
          @node_context = node_context
          @index = RubyLsp::Support::Decorators::IndexDecorator.new global_state.index

          dispatcher.register(self, :on_call_node_enter)
        end

        #: (Prism::CallNode) -> void
        def on_call_node_enter(node)
          return unless valid?(node)

          # Guessing the data type
          inferred_type = infer_type(@node_context, @index)
          return if inferred_type.nil?

          method_candidates = @index.method_completion_candidates(nil, inferred_type.name).select do |e|
            next if e.visibility != RubyIndexer::Entry::Visibility::PUBLIC

            # Filter methods from the common ancestors to focus only on methods from Dry::Struct and defined class
            object_ancestors = @index.linearized_ancestors_of(inferred_type.name) - COMMON_ANCESTORS

            object_ancestors.include?(e.owner.name)
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

              kind: Constant::CompletionItemKind::METHOD,
              data: {
                owner_name: indexer_entry&.name,
                guessed_type: indexer_entry.owner.name,
              },
            )
          end
        end

        private

        # The inferred_type is the method argument of `define_handler_for`
        #: (RubyLsp::NodeContext, RubyLsp::Support::Decorators::IndexDecorator) -> (RubyLsp::TypeInferrer::GuessedType | nil)
        def infer_type(node_context, index)
          method_argument = get_method_argument(node_context)
          return nil if method_argument.nil?

          entry = index.find_entry(method_argument[:name], method_argument[:namespaces])

          RubyLsp::TypeInferrer::GuessedType.new(entry.name) if entry
        end

        # Gets the first parameter of the block
        #
        # Example:
        # ```
        # define_handler_for(Abc) do |event|
        # end
        # ```
        # The value will be `event`
        #
        # From the existing pattern, we assume that the block contains a single parameter
        #
        # (RubyLsp::NodeContext) -> (Prism::RequiredParameterNode | nil)
        def first_block_param(node_context)
          first_param = block_parameters(node_context).first

          first_param.is_a?(Prism::RequiredParameterNode) ? first_param : nil
        end

        #: (RubyLsp::NodeContext) -> ((Array[Prism::RequiredParameterNode | Prism::MultiTargetNode]) | [])
        def block_parameters(node_context)
          call_node_block = node_context.call_node&.block

          return [] unless call_node_block.is_a?(Prism::BlockNode)
          return [] unless call_node_block.parameters.is_a?(Prism::BlockParametersNode)
          return [] unless call_node_block.parameters.parameters.is_a?(Prism::ParametersNode)

          # BlockNode -> BlockParametersNode -> ParametersNode -> Array[RequiredParameterNode]
          call_node_block.parameters.parameters.requireds
        end

        #: (RubyLsp::NodeContext) -> { name: String, namespaces: Array[String]}?
        def get_method_argument(node_context)
          argument = node_context.call_node&.arguments&.arguments&.first #: Prism::ConstantPathNode | Prism::ConstantReadNode | nil
          return nil if argument.nil?

          name = argument.name.to_s
          namespaces = argument.slice.split('::') - [name]

          { name:, namespaces: }
        end

        #: () -> bool
        def inside_define_handler_for_block?
          @node_context&.call_node&.name == COMPLETION_FOR_METHOD
        end

        #: (Prism::CallNode) -> bool
        def receiver_is_block_param?(node)
          block_parameter = first_block_param(@node_context)
          receiver = node.receiver

          receiver.is_a?(Prism::LocalVariableReadNode) && receiver.name == block_parameter&.name
        end

        #: (Prism::CallNode) -> bool
        def valid?(node)
          inside_define_handler_for_block? && receiver_is_block_param?(node)
        end
      end
    end
  end
end
