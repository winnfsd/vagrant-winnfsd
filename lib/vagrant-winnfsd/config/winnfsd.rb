require 'vagrant'

module VagrantWinNFSd
  module Config
    class WinNFSd < Vagrant.plugin('2', :config)
      attr_accessor :uid
      attr_accessor :gid

      def initialize
        @uid = UNSET_VALUE
        @gid = UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << 'winnfsd.uid cannot be nil.' if machine.config.winnfsd.uid.nil?
        errors << 'winnfsd.gid cannot be nil.' if machine.config.winnfsd.gid.nil?

        { "WinNFSd" => errors }
      end

      def finalize!
        @uid = 0 if @uid == UNSET_VALUE
        @gid = 0 if @gid == UNSET_VALUE
      end
    end
  end
end
