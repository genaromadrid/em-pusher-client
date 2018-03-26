# frozen_string_literal: true

RSpec.describe EM::Pusher::Client::MsgParser do
  def build_msg(msg)
    instance_double(
      'WebSocket::Frame::Incoming::Client',
      data: msg,
      to_s: msg,
    )
  end

  let!(:conn_established) do
    '{"event":"pusher:connection_established",' \
      '"data":"{\\"socket_id\\":\\"1565.1495770\\"}"}'
  end

  let!(:conn_error) do
    '{"event":"pusher:error","data":{"code":4001,' \
      '"message":"Did you forget to specify the cluster ' \
      'when creating the Pusher instance?  App key sdfdfd823 ' \
      'does not exist in this cluster."}}'
  end

  let!(:malformed) do
    '{"event":"pusher:someevent",' \
      '"data":"{\\"blah\\"}"}'
  end

  describe 'good parser' do
    context 'when data is a string' do
      let!(:parser) { described_class.new(build_msg(conn_established)) }

      it { expect(parser.event).to eq('pusher:connection_established') }
      it { expect(parser.data['socket_id']).to eq('1565.1495770') }
      it { expect(parser.to_s).to eq(conn_established) }
    end

    # for some reason when it have errors, responds with
    # a hash instead of a string
    context 'when data is not a string. e.g. errors' do
      let!(:parser) { described_class.new(build_msg(conn_error)) }

      it { expect(parser.event).to eq('pusher:error') }
      it { expect(parser.data['code']).to eq(4001) }
      it { expect(parser.to_s).to eq(conn_error) }
    end
  end

  describe 'bad parser' do
    context 'when json data is malformed' do
      let!(:parser) { described_class.new(build_msg(malformed)) }

      it { expect(parser.event).to eq('pusher:someevent') }
      it { expect(parser.data).to be_nil }
      it { expect(parser.to_s).to eq(malformed) }
    end
  end
end
