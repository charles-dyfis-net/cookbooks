# try for a less-broken version of Rack

include_recipe "yumrepo::epel"
include_recipe "yumrepo::elff"
include_recipe "yumrepo::annvix"

package "libxml2-devel"
package "libxslt-devel"

file "/etc/pki/rpm-gpg/cduffy" do
  content "-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: GnuPG v1.4.5 (GNU/Linux)\n\nmQGiBE1VB3YRBACY9BHaAsLZFy1YLlXoMKidUh9awcnTO8AToL5We3vsqtU+8ilj\n68gjftqqiEToZguaxJexMLZukOikitOlhlTlYHpXzzLoZ7CHjDlZTfB7oadeqfKp\nbGImkNSe1N0Gt6hStpHSSqx5X8emcPBuqY3P5lwp7AAnaycaH5mLCcqipwCgy0zm\nrvsesH4IJPZh4ssYqplxr+ED+gL7lqOv69HunjOHqXi6oqy6xyaHNLPSI/No2bc4\nFRb0C9ICjg1k/rGJL8/rcef2RDf13bu3R8AAiNhzaZBGRrHzoKjNwQ8HlKOa+fHo\nf9P72vasVYR+tsZc6J3sp5SNwlWW9lqr+w/fAa48a50ymUkcfrrAjfF+XX6L0gEl\ngVqDA/9edweyThRYqDK/2cbekoduADBfkzIh7yo7YNN5pXZlU31A+kKvlG0DRZQ1\n2LSfu5DeaJSjS3smTdxEX5/+ZFfEs5kdrJ8NsN9l5PglngwCfMuxzdQQLna2zMkg\noWrwcSCziVcaCC5FfHYNvV7xD2qTFu+VBrHqMAcMpBjR9ue5ZLQvQ2hhcmxlcyBE\ndWZmeSAoVGlwcHIsIEluYy4pIDxjaGFybGVzQHRpcHByLmNvbT6IYAQTEQIAIAUC\nTVUHdgIbAwYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEBqtqKjqAcqmHVAAnj7V\nSUzp2K1g04JJxWSdmobgkqqCAJwJKl80VjHAmWzaCDsSiFZMLKKLMLkCDQRNVQd/\nEAgA8I5SKIeoDz1kx2n57A24L4BBYLEy9PXCCSqiK4454wU4bh+xfbS99j/KRa8O\nyNcd04EZXtH0d0xBwGM7kOthxH9beTloHwDqd5aq0W+GxoCA/YQzc2cbNevhGEiN\nIFoLBO52l+Ki7S4tX1ji3U3Lfxpplyd71Zla2CnPfh2w6HgnxbmuKZq335y1y6QO\nVu3C2ewb7eMjCjbP3ySzZLixf6Dp1a+RwkWKi2LQgnzJ3wtT6T0g9CUsqWJ0hxj1\n0di7ftc4B1G4c575IALYWf3USueb1gQVCMg569XMU7AHGyuJ73ToIcy9sTImkQ8M\nf5IUwFrIaoisaWxxU8vGfNdq/wADBQf8CoUNr2diFp2KvRvPWMRCHc3Mx4lg00Y7\nFzYGC4n9xZUHvIidYAVgvXhIbauPb7MjjDN7IRebcrZzECCfmLXcn3JRaRHxTmL1\n5ZKptt5mgcmA0uVRTbu/YJ8v1otgkgWuZ0F0Ed8D66SSZb9x+twZAT1J/DUf9QrF\nmbsik3aTlFrnRjAzcs0D0RmhsQV/pqt9jC2zo6MTMiQIYR4maSM8MeT0gZzC2yzS\nlG+bNHAlbknENpdHOGnPRDWYqyEAHcIxSRQAXe+0G2q0+xmOJqj4X44oFQxfFF7w\n7SsFcvudWTttDhxPqjy0Ji27b0PgWhI26OOXr66JCpTKNfpQpaxc84hJBBgRAgAJ\nBQJNVQd/AhsMAAoJEBqtqKjqAcqmzIwAoJIKsV6K3DJ9GPlsOKIlKiZJ3EYZAJ9I\nGL5+bzbMaDW3s/d+PXv72W95KQ==\n=qAKq\n-----END PGP PUBLIC KEY BLOCK-----\n"
  mode 0644
end
execute "install-key-cduffy" do
  command "rpm --import /etc/pki/rpm-gpg/cduffy"
  not_if "rpm -q gpg-pubkey-ea01caa6-4d550776"
end
cookbook_rpm "couchdb"

# packaging for newer 1.1.4 is presently broken
gem_package "libxml-ruby-1.1.3" do
  package_name "libxml-ruby"
  version "1.1.3"
  action :install
end

gem_package "rack-1.1.0" do
  package_name "rack"
  version "1.1.0"
  action :install
end

gem_package "rack-1.2.1" do
  package_name "rack"
  version "1.2.1"
  action :remove
end

gem_package "net-ssh-multi"

include_recipe "chef::bootstrap_server"

execute "force-thin-reinstall-if-broken" do
  not_if %q{ruby <<<"require 'rubygems'; gem 'thin'; require 'thin'; begin; Thin::HttpParser; rescue NameError; exit 1; end; exit 0"}
  command "gem install thin"
end

include_recipe "chef::server"

execute "create_admin_user" do
  command <<'EOH'
export HOME=/root
if [ ! -e /root/.chef/host.pem ] ; then
  knife configure -i -u host --defaults --yes --no-editor <<<$'\n' || exit
fi
if [ -d /shared_data ] ; then
  cp /root/.chef/host.pem /shared_data/admin.pem || exit
fi
EOH
  only_if "( test -d /shared_data && ! test -e /shared_data/admin.pem ) || ! test -e /root/.chef/host.pem"
end

# FIXME: JSON -> ::JSON in chef-server recipes
# FIXME: set chef/server_fqdn in attributes
# FIXME: enterprise ruby path (if installed) onto end of run scripts

execute "copy_validation_pem" do
  command "cp /etc/chef/validation.pem /shared_data/validation.pem"
  only_if "test -d /shared_data"
  not_if "cmp -s /etc/chef/validation.pem /shared_data/validation.pem"
end

# vim: ai et sts=2 sw=2 ts=2
