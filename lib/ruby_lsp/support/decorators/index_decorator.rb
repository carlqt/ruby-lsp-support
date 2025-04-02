# frozen_string_literal: true
# rbs_inline: enabled

module RubyLsp
  module Support
    module Decorators
      class IndexDecorator
        attr_reader :index #: RubyIndexer::Index

        # @rbs @index: RubyIndexer::Index

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

        # Fuzzy searches the methods available on the receiver
        #
        # @param name [String] - Helps with narrowing the method name
        #
        #: (String? name, String receiver_name) -> Array[RubyIndexer::Entry::Member]
        def method_completion_candidates(name, receiver)
          index.method_completion_candidates(name, receiver)
        end
      end
    end
  end
end
