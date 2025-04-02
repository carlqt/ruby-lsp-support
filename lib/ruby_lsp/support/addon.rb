# frozen_string_literal: true
# rbs_inline: enabled

require 'ruby_lsp/addon'
require_relative 'definition'
require_relative 'definitions/handle_superclass'
require_relative "hover"
require_relative "hovers/jump_to_spec"
require_relative "completion"
require_relative "indexing_enhancement"

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

      #: () -> "ruby-lsp-support"
      def name
        "ruby-lsp-support"
      end

      #: () -> String
      def version
        "0.1.0"
      end

      #: (untyped, untyped, RubyLsp::NodeContext, untyped) -> untyped
      def create_definition_listener(response_builder, _uri, node_context, dispatcher)
        index = @global_state.index
        Definition.new(response_builder, node_context, index, dispatcher)
      end

      #: (untyped response_builder, RubyLsp::NodeContext node_context, untyped dispatcher) -> untyped
      def create_hover_listener(response_builder, node_context, dispatcher)
        Hover.new(response_builder, node_context, dispatcher, @global_state)
      end

      #: (untyped, untyped, RubyLsp::NodeContext, untyped) -> untyped
      def create_completion_listener(response_builder, node_context, dispatcher, _uri)
        RubyLsp::Support::Completion.new(response_builder, node_context, @global_state, dispatcher)
      end
    end
  end
end
