#
# Cookbook Name:: dwarf_fortress
# Recipe:: default
#
# Copyright 2012-2015, Jeremy Bingham
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

version = node[:df][:version]
version =~ /(\d+)\.(\d+)\.(\d+)/
df_minor = $2
df_patch = $3

tmpdir = ENV['TMP'] || ENV['TMPDIR'] || '/tmp'
df_tarball = "#{tmpdir}/#{node[:df][:version]}.tar.bz2"
df_platform = case node[:os]
  when "darwin"
    "osx"
  when "linux"
    # Other linuxes presumably need their own 32 bit libs - do later
    "linux"
end

df_extract_dir = case node[:os]
                 when 'darwin'
                   'df_osx'
                 when 'linux'
                   'df_linux'
                 end

df_source = node[:df][:source] || "http://www.bay12games.com/dwarves/df_#{df_minor}_#{df_patch}_#{df_platform}.tar.bz2"

remote_file df_tarball do
  source "#{df_source}"
  mode '0644'
end

directory "#{DF_HOME}/dwarf_fortress" do
  owner DF_USER
  mode '0755'
  action :create
end

directory "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}" do
  owner DF_USER
  mode '0755'
  action :create
end

bash 'unpack_dwarf_fortress' do
  user DF_USER
  cwd "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}"
  code <<-EOH
    tar -jxvf #{df_tarball}
  EOH
  notifies :run, "ruby_block[df_init_update]", :delayed
end

# Link extracted tarball to dwarf_fortress/current
link "#{DF_HOME}/dwarf_fortress/current" do
  action :delete
end

link "#{DF_HOME}/dwarf_fortress/current" do
  to "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}/#{df_extract_dir}"
  action :create
end

# For recent debians/ubuntus.
if node[:os] == "linux"
  case node[:platform_family]
    when "debian"
      # install 32 bit libs - TODO: on the off chance we're 32 bit Linux, we 
      # don't want to do it this way
      package "multiarch-support" do
	action :install
      end
      bash "add-i386" do
	user "root"
	code <<-EOH
	  dpkg --add-architecture i386
	  apt-get update
	EOH
      end
      %w(libgtk2.0-0:i386 libglu1-mesa:i386 libsdl-image1.2:i386 libsdl-sound1.2:i386 libsdl-ttf2.0-0:i386 libopenal1:i386).each do |pkg|
	package pkg
      end
  end
end

# For some reason this keeps insisting on running before the tarball has been
# unpacked. Hmmm.
#
# Trying to include the init.txt in this cookbook as a template is pretty much
# guaranteed not to consistently work between versions of Dwarf Fortress, so
# instead just replace the PRINT_MODE with the value in node[:df][:output].
ruby_block "df_init_update" do
  block do
    print_mode = node[:df][:output].upcase
    init_txt = "#{DF_HOME}/dwarf_fortress/current/data/init/init.txt"
    #::File.write(init_txt, ::File.open(init_txt, &:read).gsub(/\[PRINT_MODE:2D\]/, "PRINT_MODE:#{print_mode}"))
    file = Chef::Util::FileEdit.new(init_txt)
    file.search_file_replace(/\[PRINT_MODE:2D\]/, "[PRINT_MODE:#{print_mode}]")
    file.write_file
  end
  action :nothing
end
