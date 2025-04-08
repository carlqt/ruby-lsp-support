# frozen_string_literal: true

# rbs_inline: enabled

module RubyLsp
  module Support
    module Decorators
      class IndexDecorator
        extend Forwardable

        attr_reader :index #: RubyIndexer::Index

        # @rbs @index: RubyIndexer::Index

        def_delegators :@index, :method_completion_candidates, :linearized_ancestors_of

        #: (RubyIndexer::Index) -> void
        def initialize(ruby_indexer)
          @index = ruby_indexer
        end

        # Utility method that uses `RubyIndexer::Index#resolve` to support nil name and adding a default to nesting params. Returns first entry
        #
        #: (String?, ?Array[String]) -> RubyIndexer::Entry::Class?
        def find_entry(name, nesting = [])
          search(name || '', nesting).first
        end

        # Utility method that uses `RubyIndexer::Index#resolve` to add a default to nesting param
        #
        #: (String name, ?Array[String] nesting) -> Array[RubyIndexer::Entry::Class | untyped]
        def search(name, nesting = [])
          index.resolve(name, nesting) || []
        end

        # @rbs!
        #   # Returns the list of ancestors/parents of a class
        #   def linearized_ancestors_of: (String) -> Array[String]
        #
        #   # Fuzzy searches the methods available on the receiver
        #   def method_completion_candidates: (String? name, String receiver_name) -> Array[RubyIndexer::Entry::Member]
      end
    end
  end
end
