require 'vagrant'
require Vagrant.source_root.join("plugins/synced_folders/nfs/synced_folder")

module VagrantWinNFSd
  class SyncedFolder < VagrantPlugins::SyncedFolderNFS::SyncedFolder
    def enable(machine, folders, nfsopts)
      raise Vagrant::Errors::NFSNoHostIP unless nfsopts[:nfs_host_ip]
      raise Vagrant::Errors::NFSNoGuestIP unless nfsopts[:nfs_machine_ip]

      if machine.guest.capability?(:nfs_client_installed)
        installed = machine.guest.capability(:nfs_client_installed)
        unless installed
          can_install = machine.guest.capability?(:nfs_client_install)
          raise Vagrant::Errors::NFSClientNotInstalledInGuest unless can_install
          machine.ui.info I18n.t("vagrant.actions.vm.nfs.installing")
          machine.guest.capability(:nfs_client_install)
        end
      end

      machine_ip = nfsopts[:nfs_machine_ip]
      machine_ip = [machine_ip] unless machine_ip.is_a?(Array)

      # Prepare the folder, this means setting up various options
      # and such on the folder itself.
      folders.each { |id, opts| prepare_folder(machine, opts) }

      # Determine what folders we'll export
      export_folders = folders.dup
      export_folders.keys.each do |id|
        opts = export_folders[id]
        if opts.has_key?(:nfs_export) && !opts[:nfs_export]
          export_folders.delete(id)
        end
      end

      # Export the folders. We do this with a class-wide lock because
      # NFS exporting often requires sudo privilege and we don't want
      # overlapping input requests. [GH-2680]
      @@lock.synchronize do
        begin
          machine.env.lock("nfs-export") do
            machine.ui.info I18n.t("vagrant.actions.vm.nfs.exporting")
            machine.env.host.capability(
              :nfs_export,
              machine.ui, machine.id, machine_ip, export_folders)
          end
        rescue Vagrant::Errors::EnvironmentLockedError
          sleep 1
          retry
        end
      end

      # Mount
      machine.ui.info I18n.t("vagrant.actions.vm.nfs.mounting")

      # Only mount folders that have a guest path specified.
      mount_folders = {}
      folders.each do |id, opts|
        if Vagrant::Util::Platform.windows?
          unless opts[:mount_options]
            mount_opts = ["vers=#{opts[:nfs_version]}"]
            mount_opts << "udp" if opts[:nfs_udp]
            mount_opts << "nolock"

            opts[:mount_options] = mount_opts
          end

          opts[:hostpath] = '/' + opts[:hostpath].gsub(':', '').gsub('\\', '/')
        end
        mount_folders[id] = opts.dup if opts[:guestpath]
      end

      # Mount them!
      machine.guest.capability(
        :mount_nfs_folder, nfsopts[:nfs_host_ip], mount_folders)
    end
  end
end
