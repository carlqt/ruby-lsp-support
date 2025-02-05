# frozen_string_literal: true

module RubyLsp # rubocop:disable SeekPass/NamespacedDomain
  module SeekPass
    class Completion
      def initialize(response_builder, node_context, global_state, dispatcher)
        @response_builder = response_builder
        @node_context = node_context
        @index = global_state.index
        @nesting = node_context.nesting
        @type_inferrer = global_state.type_inferrer

        dispatcher.register(self, :on_call_node_enter,
                            :on_local_variable_write_node_enter,
                            :on_local_variable_and_write_enter,
                            :on_instance_variable_write_node_enter,
                            :on_instance_variable_and_write_node_enter,
                            :on_instance_variable_operator_write_node_enter,
                            :on_instance_variable_or_write_node_enter,
                            :on_instance_variable_target_node_enter)
      end

      def on_local_variable_write_node_enter(node)
        puts "Tinatamad na ako"
      end

      def on_local_variable_and_write_enter(node)
        puts "Hello Ruby World"
      end

      # TODO:
      # - Find the local variable from the block
      # - Get the correct type
      #   - Need to implement index enchancement
      # - Assign the type to the local variable
      def on_call_node_enter(node)
        entry = @index.resolve('Foo', []).first
        type = RubyLsp::TypeInferrer::GuessedType.new(entry.name)
        # method_name = @trigger_character == "." ? nil : name

        range = node.message_loc

        puts "log: #{node.message}"

        # method_completion_candidates params
        # 1st param - method name. Can be blank which will return all possible methods
        # 2nd param - Receiver. 'Foo' is a receiver

        # puts @index.method_completion_candidates(name, type.name)

        label_details = Interface::CompletionItemLabelDetails.new(
          description: 'some_file.rb',
          # detail: entry.decorated_parameters,
        )

        @response_builder << Interface::CompletionItem.new(
          label_details:,
          # The method name available
          label: 'ang_hirap_method',
          filter_text: entry.name,
          # text_edit:
          kind: Constant::CompletionItemKind::METHOD,
          data: {
            owner_name: entry&.name,
            guessed_type: type,
          },
        )
      end

      # Questions:
      # - Do I need to be concerned about the @trigger_character ?

      # Triggered on @foo =
      def on_instance_variable_write_node_enter(node)
        puts "Hello Instance Variable"
      end

      def on_instance_variable_and_write_node_enter(node)
        puts "And write node enter"
      end

      def on_instance_variable_operator_write_node_enter(node)
        puts "Operator write node enter"
      end

      def on_instance_variable_or_write_node_enter(node)
        puts "Hello Instance Variable Or Write"
      end

      def on_instance_variable_target_node_enter(node)
        puts "Instance Variable Target Node Enter"
      end
    end
  end
end
