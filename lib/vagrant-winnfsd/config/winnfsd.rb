require 'vagrant'

module VagrantWinNFSd
  module Config
    class WinNFSd < Vagrant.plugin('2', :config)
      attr_accessor :logging
      attr_accessor :uid
      attr_accessor :gid
      attr_accessor :host_ip
      attr_accessor :stop_on_reload

      def initialize
        @logging        = UNSET_VALUE
        @uid            = UNSET_VALUE
        @gid            = UNSET_VALUE
        @host_ip        = UNSET_VALUE
        @stop_on_reload = UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors << 'winnfsd.logging can only be \'on\' or \'off\'.'        unless ['on', 'off'].include?(machine.config.winnfsd.logging)
        errors << 'winnfsd.uid cannot be nil.'                            if machine.config.winnfsd.uid.nil?
        errors << 'winnfsd.gid cannot be nil.'                            if machine.config.winnfsd.gid.nil?
        errors << 'winnfsd.host_ip cannot be nil.'                        if machine.config.winnfsd.host_ip.nil?
        errors << 'winnfsd.stop_on_reload can only be \'on\' or \'off\'.' unless ['on', 'off'].include?(machine.config.winnfsd.stop_on_reload)

        { "WinNFSd" => errors }
      end

      def finalize!
        @logging = 'off'         if @logging == UNSET_VALUE
        @uid = 0                 if @uid == UNSET_VALUE
        @gid = 0                 if @gid == UNSET_VALUE
        @host_ip = ""            if @host_ip == UNSET_VALUE
        @stop_on_reload = 'off'  if @stop_on_reload == UNSET_VALUE
      end
    end
  end
end
