begin
  require 'vagrant'
rescue LoadError
  raise "The Vagrant WinNFSd plugin must be run within Vagrant."
end

if Vagrant::VERSION < "1.4.0"
  raise "The Vagrant AWS plugin is only compatible with Vagrant 1.4.0+"
end

module VagrantPlugins
  module VagrantWinNFSd
    class Plugin < Vagrant.plugin(2)
      name 'WinNFSd'

      description <<-DESC
      This plugin adds NFS support on Windows for Vagrant.
      DESC

      action_hook(:init_i18n, :environment_load) { init_plugin }

      config("vm") do |env|
        require_relative "config"
        Config
      end

      synced_folder("nfs") do
        require_relative "synced_folder"
        SyncedFolder
      end

      host("windows") do
        require_relative "host"
        Host
      end

      def self.init_plugin
        I18n.load_path << File.expand_path('locales/en.yml', VagrantWinNFSd.source_root)
        I18n.reload!

        rule_name = "VagrantWinNFSd"
        program = VagrantWinNFSd.get_path_for_file("winnfsd.exe")
        rule_exist = "netsh advfirewall firewall show rule name=\"%s\">nul"

        unless system(sprintf(rule_exist, rule_name))
          rule = "netsh advfirewall firewall add rule name=\"%s\" dir=\"%s\" action=allow protocol=any program=\"%s\" profile=any>nul"
          in_rule = sprintf(rule, rule_name, 'in', program)
          out_rule = sprintf(rule, rule_name, 'out', program)

          if !system(in_rule) || !system(out_rule)
            puts I18n.t("vagrant_winnfsd.firewall.error")
            puts "#{in_rule}\n"
            puts "#{out_rule}\n"
          end
        end
      end
    end
  end
end