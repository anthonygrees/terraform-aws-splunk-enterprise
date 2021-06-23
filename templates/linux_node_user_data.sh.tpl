install_splunk() {
    echo " ************************"
    echo " **** Install Splunk ****"
    echo " ************************"
    cd /opt
    sudo mkdir splunk 
    cd /opt/splunk
    sudo wget -O splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.3&product=splunk&filename=splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb&wget=true'
    sudo dpkg -i /opt/splunk/splunk-8.1.3-63079c59e632-linux-2.6-amd64.deb
    sudo /opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd ${splunk_password}
}

set_profile() {
    echo " ************************"
    echo " **** Set .profile  ****"
    echo " ************************"
    sudo touch ~/.profile
    sudo echo export SPLUNK_HOME=/opt/splunk >> ~/.profile
    sudo echo export SPLUNK_DB=/opt/splunk/var/lib/splunk/defaultdb >> ~/.profile
    cat ~/.profile
}

install_splunk
set_profile
