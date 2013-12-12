require 'vagrant'
require Vagrant.source_root.join("plugins/synced_folders/nfs/synced_folder")

module VagrantPlugins
  module VagrantWinNFSd
    class SyncedFolder < VagrantPlugins::SyncedFolderNFS::SyncedFolder
      def enable(machine, folders, nfsopts)
        raise Vagrant::Errors::NFSNoHostIP if !nfsopts[:nfs_host_ip]
        raise Vagrant::Errors::NFSNoGuestIP if !nfsopts[:nfs_machine_ip]

        machine_ip = nfsopts[:nfs_machine_ip]
        machine_ip = [machine_ip] if !machine_ip.is_a?(Array)

        # Prepare the folder, this means setting up various options
        # and such on the folder itself.
        folders.each { |id, opts| prepare_folder(machine, opts) }

        # Export the folders
        machine.ui.info I18n.t("vagrant.actions.vm.nfs.exporting")
        machine.env.host.nfs_export(machine.id, machine_ip, folders)

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
end