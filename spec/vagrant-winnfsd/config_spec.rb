require "vagrant-winnfsd/config"

describe VagrantPlugins::VagrantWinNFSd::Config do
  let(:instance) { described_class.new }

  before :each do
    ENV.stub(:[] => nil)
  end

  #TODO
end
