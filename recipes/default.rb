#
# Cookbook Name:: dwarf_fortress
# Recipe:: default
#
# Copyright 2012, Jeremy Bingham
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

# Right now we're just going to start with Mac and Linux support, but hopefully
# some brave soul will help with Windows. BSD and Solaris might be doable
# as well with the Linx binaries though.

df_downloads = [ :mac_os_x => "http://www.bay12games.com/dwarves/df_34_09_osx.tar.bz2", :linux => "http://www.bay12games.com/dwarves/df_34_09_linux.tar.bz2" ]

tmpdir = ENV['TMP'] || ENV['TMPDIR'] || "/tmp"
df_tarball = "#{tmpdir}/df-#{$$}.tar.bz2"
df_platform = case node[:platform_family]
  when "mac_os_x"
    :mac_os_x
  when "debian"
    # Other linuxes presumably need their own 32 bit libs - do later
    :linux
end

df_extract_dir = case node[:platform_family]
  when "mac_os_x"
    "df_osx"
  when "debian"
    "df_linux"
end

df_source = node[:df][:source] || df_downloads[df_platform]

remote_file df_tarball do
  source df_source
  mode "0644"
end

directory "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]"
  recursive true
  owner DF_USER
  mode "0755"
  action :create
end

bash "unpack_dwarf_fortress" do
  user DF_USER
  cwd "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]"
  code <<-EOH
    tar -jxvf #{df_tarball}
  EOH
end

file df_tarball do
  action :delete
end

# Link extracted tarball to dwarf_fortress/current
link "#{DF_HOME}/dwarf_fortress/current" do
  source "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]/#{df_extract_dir}"
  owner DF_USER
end

# TODO: With linux, we'll need to install some libs at this point.
