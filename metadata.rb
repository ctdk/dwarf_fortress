maintainer 'Jeremy Bingham'
maintainer_email 'jbingham@gmail.com'
license 'MIT'
description 'Installs/Configures dwarf_fortress'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.2.2'
name 'dwarf-fortress'

%w(mac_os_x debian).each do |os|
  supports os
end

attribute 'df',
          display_name: 'Dwarf Fortress hash',
          description: 'Hash of Dwarf Fortress attributes',
          type: 'hash'

attribute 'df/source',
          display_name: 'Dwarf Fortress source URL',
          description: 'Optional alternal source URL for downloading Dwarf Fortress'

attribute 'df/version',
          display_name: 'Dwarf Fortress version',
          description: 'Dwarf Fortress version string',
          default: 'df_0.34.10'
