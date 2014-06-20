require Vagrant.source_root.join('plugins/hosts/windows/cap/nfs')

module VagrantWinNFSd
  module Cap
    class NFS < Vagrant.plugin('2', :host)
      @logger = Log4r::Logger.new('vagrant::hosts::windows')

      executable = VagrantWinNFSd.get_path_for_file('nfsservice.bat')
      @nfs_check_command = "\"#{executable}\" status"
      @nfs_start_command = "\"#{executable}\" start"
      @nfs_stop_command = "\"#{executable}\" halt"
      @nfs_path_file = "#{Vagrant.source_root}/nfspaths"

      def self.nfs_export(env, ui, id, ips, folders)
        ui.info I18n.t('vagrant_winnfsd.hosts.windows.nfs_export')
        sleep 0.5

        self.nfs_cleanup(id)
        nfs_file_lines = []

        nfs_file_lines.push("# VAGRANT-BEGIN: #{Process.uid} #{id}")
        folders.each do |k, opts|
          hostpath = opts[:hostpath].dup
          hostpath.gsub!("'", "'\\\\''")
          hostpath.gsub('/', '\\')
          nfs_file_lines.push("#{hostpath}")
        end
        nfs_file_lines.push("# VAGRANT-END: #{Process.uid} #{id}")

        File.open(@nfs_path_file, 'a') do |f|
          f.puts(nfs_file_lines)
        end



        unless self.nfs_running?
          gid = env.vagrantfile.config.winnfsd.gid
          uid = env.vagrantfile.config.winnfsd.uid
          logging = env.vagrantfile.config.winnfsd.logging
          system("#{@nfs_start_command} #{logging} #{@nfs_path_file} #{uid} #{gid}")
          sleep 2
        end
      end

      def self.nfs_prune(environment, ui, valid_ids)
        return unless File.exist?(@nfs_path_file)

        @logger.info('Pruning invalid NFS entries...')

        output = false
        user = Process.uid

        File.read(@nfs_path_file).lines.each do |line|
          id = line[/^# VAGRANT-BEGIN:( #{user})? ([A-Za-z0-9-]+?)$/, 2]

          if id
            if valid_ids.include?(id)
              @logger.debug("Valid ID: #{id}")
            else
              unless output
                # We want to warn the user but we only want to output once
                ui.info I18n.t('vagrant_winnfsd.hosts.windows.nfs_prune')
                output = true
              end

              @logger.info("Invalid ID, pruning: #{id}")
              self.nfs_cleanup(id)
            end
          end
        end
      end

      def self.nfs_installed(environment)
        true
      end

      protected

      def self.nfs_running?
        system("#{@nfs_check_command}")
      end

      def self.nfs_cleanup(id)
        return unless File.exist?(@nfs_path_file)

        user = Regexp.escape(Process.uid.to_s)
        id   = Regexp.escape(id.to_s)
        skip = false
        new_file_lines = []

        File.read(@nfs_path_file).lines.each do |line|
          if line[/^# VAGRANT-BEGIN: #{user} #{id}$/]
            skip = true
          elsif line[/^# VAGRANT-END: #{user} #{id}$/]
            skip = false
          elsif !skip
             new_file_lines.push(line)
          end
        end

        File.open(@nfs_path_file, 'w+') do |f|
          f.puts(new_file_lines)
        end
      end
    end
  end
end
