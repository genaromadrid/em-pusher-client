# frozen_string_literal: true

RSpec.describe EM::Pusher::Client do
  let!(:scheme)   { EM::Pusher::Client::DEFAULT_OPTIONS[:scheme] }
  let!(:protocol) { EM::Pusher::Client::DEFAULT_OPTIONS[:protocol] }
  let!(:version)  { EM::Pusher::Client::DEFAULT_OPTIONS[:version] }
  let!(:client)   { EM::Pusher::Client::DEFAULT_OPTIONS[:client_name] }
  let!(:port)     { EM::Pusher::Client::DEFAULT_OPTIONS[:port] }
  let(:expected_url) do
    "#{scheme}://ws-#{cluster}.pusher.com:#{port}" \
      "/app/#{key}" \
      "?protocol=#{protocol}" \
      "&client=#{client}" \
      "&version=#{version}"
  end

  describe '#connect' do
    context 'when using defaults' do
      let!(:key) { 'my-key' }
      let!(:cluster) { 'us2' }

      it 'calls Connection with constructed url' do
        allow(EM::Pusher::Client::Connection).to receive(:connect)
        described_class.connect(key: key, cluster: cluster)
        expect(EM::Pusher::Client::Connection).to(
          have_received(:connect).with(expected_url),
        )
      end
    end

    context 'when using other settings' do
      let!(:key) { 'my-key' }
      let!(:cluster) { 'us2' }
      let!(:port) { 80 }
      let!(:scheme) { 'ws' }

      it 'calls Connection with constructed url' do
        allow(EM::Pusher::Client::Connection).to receive(:connect)
        described_class.connect(
          key: key,
          cluster: cluster,
          port: port,
          scheme: scheme,
        )
        expect(EM::Pusher::Client::Connection).to(have_received(:connect).with(expected_url))
      end
    end

    context 'when bad params' do
      it 'fails' do
        expect do
          described_class.connect(key: 'key')
        end.to raise_error(ArgumentError)
      end
    end
  end
end
