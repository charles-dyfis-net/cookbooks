Overview
========

This repository contains cookbooks required to bootstrap a Chef server.  For
the most part, it is an out-of-date subset of the upstream opscode-cookbooks
repo, and should not be used by anyone.

However, it includes some useful items for folks destroying Chef on CentOS 5:

* A packaged post-1.0 release of CouchDB
* Known-good gem versions

The included script `install_deps` should install all necessary dependencies on
a clean CentOS 5 system.

To use, apply the `centos_chef_deploy` cookbook via `chef-solo`.
