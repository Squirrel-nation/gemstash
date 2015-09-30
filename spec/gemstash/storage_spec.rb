require "spec_helper"
require "securerandom"

describe Gemstash::Storage do
  before do
    @folder = Dir.mktmpdir
  end
  after do
    FileUtils.remove_entry(@folder) if File.exist?(@folder)
  end

  it "builds with a valid folder" do
    expect(Gemstash::Storage.new(@folder)).not_to be_nil
  end

  it "builds the path if it does not exists" do
    new_path = File.join(@folder, "other-path")
    expect(Dir.exist?(new_path)).to be_falsy
    Gemstash::Storage.new(new_path)
    expect(Dir.exist?(new_path)).to be_truthy
  end

  context "with a valid storage" do
    let(:storage) { Gemstash::Storage.new(@folder) }

    it "can create a child storage from itself" do
      storage.for("gems")
      expect(Dir.exist?(File.join(@folder, "gems"))).to be_truthy
    end

    it "returns a non existing resource when requested" do
      resource = storage.resource("an_id")
      expect(resource).not_to be_nil
      expect(resource).not_to exist
    end

    context "with a simple resource" do
      let(:resource) { storage.resource("an_id") }

      it "can be saved" do
        resource.save("content")
        expect(resource).to exist
      end

      it "can be read afterwards" do
        resource.save("some content")
        expect(resource.content).to eq("some content")
      end

      it "can also save properties" do
        resource.save("some other content", properties: { "content-type" => "octet/stream" })
        expect(resource.content).to eq("some other content")
        expect(resource.properties).to eq("content-type" => "octet/stream")
      end
    end

    context "with a previously stored resource" do
      let(:resource_id) { SecureRandom.uuid }
      let(:content) { SecureRandom.base64 }
      before do
        storage.resource(resource_id).save(content)
      end

      it "loads the content from disk" do
        resource = storage.resource(resource_id)
        resource.load
        expect(resource.content).to eq(content)
      end
    end
  end
end
