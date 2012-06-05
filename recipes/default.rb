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

df_downloads = { :mac_os_x => "http://www.bay12games.com/dwarves/df_34_11_osx.tar.bz2", :linux => "http://www.bay12games.com/dwarves/df_34_11_linux.tar.bz2" }

tmpdir = ENV['TMP'] || ENV['TMPDIR'] || "/tmp"
df_tarball = "#{tmpdir}/#{node[:df][:version]}.tar.bz2"
df_platform = case node[:os]
  when "darwin"
    :mac_os_x
  when "linux"
    # Other linuxes presumably need their own 32 bit libs - do later
    :linux
end

df_extract_dir = case node[:os]
  when "darwin"
    "df_osx"
  when "linux"
    "df_linux"
end

if node[:df][:source]
  df_source = node[:df][:source]
else
  df_source = df_downloads[df_platform]
end

remote_file df_tarball do
  source "#{df_source}"
  mode "0644"
end

directory "#{DF_HOME}/dwarf_fortress" do
  owner DF_USER
  mode "0755"
  action :create
end

directory "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}" do
  owner DF_USER
  mode "0755"
  action :create
end

bash "unpack_dwarf_fortress" do
  user DF_USER
  cwd "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}"
  code <<-EOH
    tar -jxvf #{df_tarball}
  EOH
end

# Link extracted tarball to dwarf_fortress/current
link "#{DF_HOME}/dwarf_fortress/current" do
  action :delete
end

link "#{DF_HOME}/dwarf_fortress/current" do
  to "#{DF_HOME}/dwarf_fortress/#{node[:df][:version]}/#{df_extract_dir}"
  action :create
end

# TODO: With linux, we'll need to install some libs at this point.
if node[:os] == "linux"
  case node[:platform]
    # TODO: Test that debian files will work with Ubuntu
    when "debian", "ubuntu"
      # install 32 bit libs - TODO: on the off chance we're 32 bit Linux, we 
      # don't want to do it this way
      package "ia32-libs" do
	action :upgrade
      end
      package "ia32-libs-gtk" do
	action :upgrade
      end
      remote_file "#{tmpdir}/libsdl-ttf2.0-0_2.0.9-1_i386.deb" do
	source "http://ftp.us.debian.org/debian/pool/main/s/sdl-ttf2.0/libsdl-ttf2.0-0_2.0.9-1_i386.deb"
	mode "0644"
      end
      remote_file "#{tmpdir}/libsdl-image1.2_1.2.10-2+b2_i386.deb" do
	source "http://ftp.us.debian.org/debian/pool/main/s/sdl-image1.2/libsdl-image1.2_1.2.10-2+b2_i386.deb"
	mode "0644"
      end
      bash "install_32bit_libs" do
	user "root"
	cwd tmpdir
	code <<-EOH
	  dpkg -x libsdl-image1.2_1.2.10-2+b2_i386.deb .
	  dpkg -x libsdl-ttf2.0-0_2.0.9-1_i386.deb .
	  cp usr/lib/* /usr/lib32/
	  cd /usr/lib32
	  ln -s libopenal.so.1 libopenal.so
	  ln -s libsndfile.so.1 libsndfile.so
	  ln -s libSDL_ttf-2.0.so.0 libSDL_ttf-2.0.so
	EOH
      end
    # TODO: test Arch linux too.
    when "arch"
      %w{ lib32-gtk2 lib32-libsndfile lib32-libxdamage lib32-mesa lib32-ncurses lib32-openal lib32-sdl_image lib32-sdl_ttf }.each do |arch_pkg|
	package arch_pkg do
	  action :install
	end
      end
    # TODO: this cover CentOS?
    when "fedora"

    end
  end
end
