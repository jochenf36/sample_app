require 'spec_helper'

describe Listen::Listener do
  let(:listener) { Listen::Listener.new(options) }
  let(:options) { {} }
  let(:registry) { double(Celluloid::Registry, :[]= => true) }
  let(:supervisor) { double(Celluloid::SupervisionGroup, add: true, pool: true) }
  let(:record) { double(Listen::Record, terminate: true, build: true) }
  let(:silencer) { double(Listen::Silencer, terminate: true) }
  let(:adapter) { double(Listen::Adapter::Base) }
  let(:change_pool) { double(Listen::Change, terminate: true) }
  let(:change_pool_async) { double('ChangePoolAsync') }
  before {
    Celluloid::Registry.stub(:new) { registry }
    Celluloid::SupervisionGroup.stub(:run!) { supervisor }
    registry.stub(:[]).with(:silencer) { silencer }
    registry.stub(:[]).with(:adapter) { adapter }
    registry.stub(:[]).with(:record) { record }
    registry.stub(:[]).with(:change_pool) { change_pool }

  }

  describe "initialize" do
    it "sets paused to false" do
      expect(listener).not_to be_paused
    end

    it "sets block" do
      block = Proc.new { |modified, added, removed| }
      listener = Listen::Listener.new('lib', &block)
      expect(listener.block).not_to be_nil
    end

    it "sets directories with realpath" do
      listener = Listen::Listener.new('lib', 'spec')
      expect(listener.directories).to eq [Pathname.new("#{Dir.pwd}/lib"), Pathname.new("#{Dir.pwd}/spec")]
    end
  end

  describe "options" do
    it "sets default options" do
      expect(listener.options).to eq({
        debug: false,
        latency: nil,
        wait_for_delay: 0.1,
        force_polling: false,
        polling_fallback_message: nil })
    end

    it "sets new options on initialize" do
      listener = Listen::Listener.new('lib', latency: 1.234, wait_for_delay: 0.85)
      expect(listener.options).to eq({
        debug: false,
        latency: 1.234,
        wait_for_delay: 0.85,
        force_polling: false,
        polling_fallback_message: nil })
    end
  end

  describe "#start" do
    before {
      adapter.stub_chain(:async, :start)
    }

    it "traps INT signal" do
      expect(Signal).to receive(:trap).with('INT')
      listener.start
    end

    it "registers silencer" do
      expect(supervisor).to receive(:add).with(Listen::Silencer, as: :silencer, args: listener)
      listener.start
    end

    it "supervises change_pool" do
      expect(supervisor).to receive(:pool).with(Listen::Change, as: :change_pool, args: listener)
      listener.start
    end

    it "supervises adaper" do
      Listen::Adapter.stub(:select) { Listen::Adapter::Polling }
      expect(supervisor).to receive(:add).with(Listen::Adapter::Polling, as: :adapter, args: listener)
      listener.start
    end

    it "supervises record" do
      expect(supervisor).to receive(:add).with(Listen::Record, as: :record, args: listener)
      listener.start
    end

    it "builds record" do
      expect(record).to receive(:build)
      listener.start
    end

    it "sets paused to false" do
      listener.start
      expect(listener.paused).to be_false
    end

    it "starts adapter asynchronously" do
      async_stub = double
      expect(adapter).to receive(:async) { async_stub }
      expect(async_stub).to receive(:start)
      listener.start
    end

    it "starts adapter asynchronously" do
      async_stub = double
      expect(adapter).to receive(:async) { async_stub }
      expect(async_stub).to receive(:start)
      listener.start
    end

    it "calls block on changes" do
      listener.changes = [{ modified: 'foo' }]
      block_stub = double('block')
      listener.block = block_stub
      expect(block_stub).to receive(:call).with(['foo'], [], [])
      listener.start
      sleep 0.01
    end
  end

  describe "#stop" do
    let(:thread) { double(join: true) }
    before { listener.stub(:thread) { thread } }

    it "joins thread" do
      expect(thread).to receive(:join)
      listener.stop
    end
  end

  describe "#pause" do
    it "sets paused to true" do
      listener.pause
      expect(listener.paused).to be_true
    end
  end

  describe "#unpause" do
    it "builds record" do
      expect(record).to receive(:build)
      listener.unpause
    end

    it "sets paused to false" do
      record.stub(:build)
      listener.unpause
      expect(listener.paused).to be_false
    end
  end

  describe "#paused?" do
    it "returns true when paused" do
      listener.paused = true
      expect(listener).to be_paused
    end
    it "returns false when not paused (nil)" do
      listener.paused = nil
      expect(listener).not_to be_paused
    end
    it "returns false when not paused (false)" do
      listener.paused = false
      expect(listener).not_to be_paused
    end
  end

  describe "#paused?" do
    it "returns true when not paused (false)" do
      listener.paused = false
      expect(listener.listen?).to be_true
    end
    it "returns false when not paused (nil)" do
      listener.paused = nil
      expect(listener.listen?).to be_false
    end
    it "returns false when paused" do
      listener.paused = true
      expect(listener.listen?).to be_false
    end
  end

  describe "#ignore" do
    let(:new_silencer) { double(Listen::Silencer) }
    before { Celluloid::Actor.stub(:[]=) }

    it "resets silencer actor" do
      expect(Listen::Silencer).to receive(:new).with(listener) { new_silencer }
      expect(registry).to receive(:[]=).with(:silencer, new_silencer)
      listener.ignore(/foo/)
    end

    context "with existing ignore options" do
      let(:options) { { ignore: /bar/ } }

      it "adds up to existing ignore options" do
        expect(Listen::Silencer).to receive(:new).with(listener)
        listener.ignore(/foo/)
        expect(listener.options).to include(ignore: [/bar/, /foo/])
      end
    end

    context "with existing ignore options (array)" do
      let(:options) { { ignore: [/bar/] } }

      it "adds up to existing ignore options" do
        expect(Listen::Silencer).to receive(:new).with(listener)
        listener.ignore(/foo/)
        expect(listener.options).to include(ignore: [[/bar/], /foo/])
      end
    end
  end

  describe "#ignore!" do
    let(:new_silencer) { double(Listen::Silencer) }
    before { Celluloid::Actor.stub(:[]=) }

    it "resets silencer actor" do
      expect(Listen::Silencer).to receive(:new).with(listener) { new_silencer }
      expect(registry).to receive(:[]=).with(:silencer, new_silencer)
      listener.ignore!(/foo/)
      expect(listener.options).to include(ignore!: /foo/)
    end

    context "with existing ignore! options" do
      let(:options) { { ignore!: /bar/ } }

      it "overwrites existing ignore options" do
        expect(Listen::Silencer).to receive(:new).with(listener)
        listener.ignore!([/foo/])
        expect(listener.options).to include(ignore!: [/foo/])
      end
    end

    context "with existing ignore options" do
      let(:options) { { ignore: /bar/ } }

      it "deletes ignore options" do
        expect(Listen::Silencer).to receive(:new).with(listener)
        listener.ignore!([/foo/])
        expect(listener.options).to_not include(ignore: /bar/)
      end
    end
  end

  describe "#only" do
    let(:new_silencer) { double(Listen::Silencer) }
    before { Celluloid::Actor.stub(:[]=) }

    it "resets silencer actor" do
      expect(Listen::Silencer).to receive(:new).with(listener) { new_silencer }
      expect(registry).to receive(:[]=).with(:silencer, new_silencer)
      listener.only(/foo/)
    end

    context "with existing only options" do
      let(:options) { { only: /bar/ } }

      it "overwrites existing ignore options" do
        expect(Listen::Silencer).to receive(:new).with(listener)
        listener.only([/foo/])
        expect(listener.options).to include(only: [/foo/])
      end
    end
  end

end
