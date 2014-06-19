# Vagrant WinNFSd

Manage and adds support for NFS on windows.

## Supported Platforms

As of version 1.0.6 or later Vagrant 1.5 is required. For vagrant 1.4 please use the plugin version 1.0.5 or lower.

Supported guests:

  * Linux

## Installation

```
$ vagrant plugin install vagrant-winnfsd
```

## Activate NFS for vagrant

To activate NFS for vagrant see: http://docs.vagrantup.com/v2/synced-folders/nfs.html

The plugin extends vagrant in the way that you can use NFS also with windows. So the following hint on the vagrant documentation page is no longer true.

```
Windows users: NFS folders do not work on Windows hosts. Vagrant will ignore your request for NFS synced folders on Windows.
```

## Settings

You can set the uid and the gid. Example:

```
Vagrant.configure('2') do |config|
    config.winnfsd.uid = 1
    config.winnfsd.gid = 1
end
```

Note that will be set global, that means the uid and gid is taken from the first box which starts the nfs daemon. If a box with an other uid or gid is started after that the option will be ignored.