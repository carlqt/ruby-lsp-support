# frozen_string_literal: true

RSpec.describe 'jump to spec file' do
  include RubyLsp::TestHelper

  context 'when target class name has a spec file' do
    let(:source) do
      <<~RUBY
        class SampleSpec
        end
      RUBY
    end

    it 'finds the spec file' do
      with_server(source) do |server, uri|
        server.process_message(
          {
            id: 1,
            method: 'textDocument/hover',
            params: {
              textDocument: { uri: uri },
              position: { line: 0, character: 7 },
            },
          },
        )

        response = pop_result(server).response

        expect(response.contents.value).to include('**Spec file:** [sample_spec.rb](/Users/carlwilliamtablante/Projects/ruby-lsp-support/spec/ruby_lsp/support/hovers/data/sample_spec.rb)')
      end
    end
  end
end
