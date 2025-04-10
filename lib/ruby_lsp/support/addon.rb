# frozen_string_literal: true

# rbs_inline: enabled

require 'ruby_lsp/addon'
require_relative 'definitions/handle_superclass'
require_relative 'hovers/jump_to_spec'
require_relative 'completions/define_handler_for'
require_relative 'indexing_enhancement'

module RubyLsp
  module Support
    class Addon < ::RubyLsp::Addon
      # @rbs @global_state: untyped
      # @rbs @outgoing_queue: untyped

      #: (untyped, untyped) -> void
      def activate(global_state, outgoing_queue)
        @global_state = global_state
        @outgoing_queue = outgoing_queue

        @outgoing_queue.push(
          Notification.window_log_message("Activating Support LSP extension v#{version}"),
        )
      end

      # perform any cleanup tasks like shutting down a child process
      #
      #: () -> void
      def deactivate; end

      #: () -> String
      def name
        'ruby-lsp-support'
      end

      #: () -> String
      def version
        '0.2.0'
      end

      #: (untyped, untyped, RubyLsp::NodeContext, Prism::Dispatcher dispatcher) -> untyped
      def create_definition_listener(response_builder, _uri, node_context, dispatcher)
        index = @global_state.index
        RubyLsp::Support::Definitions::HandleSuperclass.new(node_context, response_builder, index, dispatcher)
      end

      #: (untyped response_builder, RubyLsp::NodeContext node_context, Prism::Dispatcher dispatcher) -> untyped
      def create_hover_listener(response_builder, node_context, dispatcher)
        RubyLsp::Support::Hovers::JumpToSpec.new(node_context, response_builder, dispatcher, @global_state)
      end

      #: (untyped response_builder, RubyLsp::NodeContext node_context, Prism::Dispatcher dispatcher, untyped _uri) -> untyped
      def create_completion_listener(response_builder, node_context, dispatcher, _uri)
        RubyLsp::Support::Completions::DefineHandlerFor.new(response_builder, node_context, @global_state, dispatcher)
      end
    end
  end
end
