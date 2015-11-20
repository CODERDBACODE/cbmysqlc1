#
# Author: Gowrish.Mallipattana
#
# Install mysql configuration files from ERB templates
#
#

# Create directories
bash 'create directories' do
  
  user "root"

  code <<-EOH
    mkdir -p #{node[:clusterDir]}
    mkdir -p #{node[:dataDir]}
  EOH

end

# Create my.cnf file from template
myCnfFile=node[:myCnfFile]
execute 'backup current my.cnf' do
  user "root"
  command "cp #{myCnfFile} #{myCnfFile}.bak"
end

template "#{myCnfFile}" do
  source 'my_cnf.erb'
   owner 'root'
   group 'root'
    mode '0755'
    variables({
     :hostnameNode1  => node[:node1][:hostName]
  })
end

# Create config.ini file from template
configIniFile=node[:configIniFile]
execute 'backup current config.ini file' do
  user "root"
  command "cp #{configIniFile} #{configIniFile}.bak"
end
template "#{configIniFile}" do
  source 'config_ini.erb'
   owner 'root'
   group 'root'
    mode '0755'
    variables({
     :hostnameNode1   => node[:node1][:hostName],
     :clusterDir      => node[:clusterDir],
     :dataDir         => node[:dataDir],
     :hostnameNode2   => node[:node2][:hostName]
  })
end

# Create link in /usr/mysql-cluster
bash 'create link in #{node[:usrClusterDir]}' do
  user "root"
  code <<-EOH
    mkdir -p #{node[:usrClusterDir]}
    cd #{node[:usrClusterDir]}
    ln -s #{configIniFile}
  EOH
end