# Vagrant WinNFSd

Manage and adds support for NFS on windows.

## Supported Platforms

As of version 1.0.0 or later Vagrant 1.4 is required.

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