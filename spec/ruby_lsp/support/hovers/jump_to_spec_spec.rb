# frozen_string_literal: true

require 'tempfile'

RSpec.describe 'jump to spec file' do
  include RubyLsp::TestHelper

  context 'when target class name has a spec file' do
    let(:source) do
      <<~RUBY
        class SampleSpec
        end
      RUBY
    end

    it 'it displays the link to the spec file when it matches "describe SampleSpec"' do
      spec_file_source = <<~RUBY
        RSpec.describe SampleSpec do
        end
      RUBY

      # tempfile = Tempfile.new("fake_spec.rb")
      # tempfile.write(spec_file_source)
      # tempfile.close

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

        path = Pathname.new(__FILE__)
        expect(response.contents.value).to include("**Spec file:** [#{path.basename.to_s}](#{path.to_s}")
      end
    end
  end

  context 'when target class name does not have a spec file' do
    let(:source) do
      <<~RUBY
        class SampleSpecx
        end
      RUBY
    end
    it 'does not display the spec file link' do
      # tempfile = Tempfile.new("fake_spec.rb")
      # tempfile.write(spec_file_source)
      # tempfile.close

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

        path = Pathname.new(__FILE__)
        expect(response.contents.value).to_not include("**Spec file:** [#{path.basename.to_s}](#{path.to_s}")
      end
    end
  end
end
