# frozen_string_literal: true

module RubyLsp
  module Support
    module Decorators
      class IndexerDecorator
        attr_reader :index

        def initialize(ruby_indexer)
          @index = ruby_indexer
        end

        # Utility method that uses `RubyIndexer::Index#resolve` to support nil name and adding a default to nesting params. Returns first entry
        def find_entry(name, nesting = [])
          search(name || '', nesting).first
        end

        # Utility method that uses `RubyIndexer::Index#resolve` to add a default to nesting param
        def search(name, nesting = [])
          index.resolve(name, nesting) || []
        end

        def method_completion_candidates(name, receiver)
          index.method_completion_candidates(name, receiver)
        end
      end
    end
  end
end
