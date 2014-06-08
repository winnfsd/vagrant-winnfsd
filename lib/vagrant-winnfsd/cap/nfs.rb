require Vagrant.source_root.join("plugins/hosts/windows/cap/nfs")

module VagrantPlugins
  module VagrantWinNFSd
    module Cap
      class NFS < Vagrant.plugin("2", :host)
        @logger = Log4r::Logger.new("vagrant::hosts::windows")

        executable = VagrantWinNFSd.get_path_for_file("nfsservice.bat")
        @nfs_check_command = "\"#{executable}\" status"
        @nfs_start_command = "\"#{executable}\" start"
        @nfs_stop_command = "\"#{executable}\" halt"
        @nfs_path_file = ".vagrant\\nfspaths"

        def self.nfs_export(env, ui, id, ips, folders)
          ui.info I18n.t("vagrant_winnfsd.hosts.windows.nfs_export")
          sleep 0.5

          folders.each do |k, opts|
            hostpath = opts[:hostpath].dup
            hostpath.gsub!("'", "'\\\\''")
            hostpath.gsub('/', '\\')
            system("echo #{hostpath} >>#@nfs_path_file")
          end

          system("#@nfs_start_command .\\#@nfs_path_file")
          sleep 2
        end

        def self.nfs_prune(environment, ui, valid_ids)
          ui.info I18n.t("vagrant_winnfsd.hosts.windows.nfs_prune")
          @logger.info("Pruning invalid NFS entries...")
          self.nfs_cleanup
        end

        def self.nfs_installed(env)
          true
        end

        protected

        def self.nfs_running?
          system("#@nfs_check_command")
        end

        def self.nfs_cleanup
          if nfs_running?
            system("#@nfs_stop_command")
          end

          if !nfs_running? && File.exist?(@nfs_path_file)
            File.delete(@nfs_path_file)
          end
        end
      end
    end
  end
end