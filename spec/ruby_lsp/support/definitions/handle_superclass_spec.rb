# frozen_string_literal: true

RSpec.describe 'handle superclass definition' do
  include RubyLsp::TestHelper

  let(:source) do
    <<~RUBY
      class Foo
        class FooInstance
          class FooToo
          end
        end
      end

      class Omega < Foo
        class OmegaInstance < superclass::FooInstance
        end
      end
    RUBY
  end

  context 'when target is a superclass' do
    it 'finds the parent class declaration' do
      with_server(source) do |server, uri|
        server.process_message(
          {
            id: 1,
            method: 'textDocument/definition',
            params: {
              textDocument: { uri: uri },
              position: { line: 8, character: 27 },
            },
          },
        )

        response = pop_result(server).response

        expect(response.count).to eq(1)
        range = response[0].target_selection_range.attributes
        range_hash = { start: range[:start].to_hash, end: range[:end].to_hash }
        expect(range_hash).to eq(
          start: { line: 0, character: 6 },
          end: { line: 0, character: 9 },
        )
      end
    end
  end

  context 'when target is a Class name with a superclass namespace' do
    it 'finds the class declaration for Class name with a superclass namespace' do
      with_server(source) do |server, uri|
        server.process_message(
          {
            id: 1,
            method: 'textDocument/definition',
            params: {
              textDocument: { uri: uri },
              position: { line: 8, character: 36 },
            },
          },
        )

        response = pop_result(server).response

        expect(response.count).to eq(1)
        range = response[0].target_selection_range.attributes
        range_hash = { start: range[:start].to_hash, end: range[:end].to_hash }
        expect(range_hash).to eq(
          start: { line: 1, character: 8 },
          end: { line: 1, character: 19 },
        )
      end
    end
  end
end
