#!/bin/bash
#=====================================================================
# Internatioinal SQL-Ledger-Network Association
# Copyright (c) 2014-2015
#
#  Author: Maik Wagner
#     Web: http://www.sql-ledger-network.com
#   Email: maiktapwagner@aol.com
#  Vers.:  0.9 (see known issues)
#
#  Based on the ledger123 Installation Script by Sebastian Weitmann
#   
#======================================================================
#
# Installation Script for SQL-Ledger Standard Version Tekki version
# for CentOS 6 
#
# Known issues: The authentication methods are not set correctly
# in the pg_hba.conf file. peer authentication doesn't work with 
# SQL Ledger, so please add "trust" (without quotes manually for
# local connections. The script has been tested on CentOS 6.6
#
#======================================================================
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details:
# <http://www.gnu.org/licenses/>.
#======================================================================
#
# This script calls the installation function.
#

# Hauptinstallationsroutine / Main installation routine

installation ()
{

clear 
echo "Updating and installing dependencies..."

cd
yum update 
yum upgrade 
yum -y install git acpid httpd postgresql perl-DBI perl-DBD-Pg git-core gitweb postfix texlive
a2ensite default-ssl
service apache2 reload
a2enmod ssl
a2enmod cgi
service apache2 restart
cd /usr/local
git clone git://github.com/Tekki/sql-ledger.git
cd /usr/local/sql-ledger
git checkout -b full origin/full
mkdir spool
chown -hR apache.apache users templates css spool
cp sql-ledger.conf.default sql-ledger.conf
cd ~/
cp sql-ledger /etc/apache2/sites-available/
cd /etc/apache2/sites-enabled/
ln -s ../sites-available/sql-ledger 001-sql-ledger

echo "AddHandler cgi-script .pl" >> /etc/httpd/conf/httpd.conf
echo "Alias /sql-ledger /usr/local/sql-ledger" >> /etc/httpd/conf/httpd.conf
echo "<Directory /usr/local/sql-ledger>" >> /etc/httpd/conf/httpd.conf
echo "Options ExecCGI Includes FollowSymlinks" >> /etc/httpd/conf/httpd.conf
echo "</Directory>" >> /etc/httpd/conf/httpd.conf
echo "<Directory /usr/local/sql-ledger/users>" >> /etc/httpd/conf/httpd.conf
echo "Order Deny,Allow" >> /etc/httpd/conf/httpd.conf
echo "Deny from All" >> /etc/httpd/conf/httpd.conf
echo "</Directory>" >> /etc/httpd/conf/httpd.conf


service apache2 restart
cd 

# Postgres Installation 
clear
echo "Initialising Postgres - Press RETURN to continue"
read confirmation
service postgresql initdb
wget http://www.sql-ledger-network.com/debian/pg_hba.conf --retr-symlinks=no
cp pg_hba.conf /var/lib/pgsql/data/
service postgresql start
su postgres -c "createuser -d -S -R sql-ledger"
}


# Main program

clear
echo "Copyright (C) 2015  International SQL-Ledger Network Associaton"
echo "This is free software, and you are welcome to redistribute it under"
echo "certain conditions; See <http://www.gnu.org/licenses/> for more details"
echo "This program comes with ABSOLUTELY NO WARRANTY"
echo "PLEASE NOTE:"
echo "This script will make some fairly major changes to your CentOS system:"
echo "- Modifying the main apache2.conf file to handle the SQL Ledger directory which will be in the default document root: /var/www/html"
echo "If you agree to these changes to your CentOS system please type 'installation'. Any other input will back you out and return to the command line."
read input

if [ "$input" = "installation" ]; then
                installation 
                clear
                echo 
                echo "Thank you for your patience! The automatic installation has now been completed."
                echo
                echo "You should now be able to login to the latest SQL-Ledger Classic version (sql-ledger) as 'admin' on http://yourserver_ip/sql-ledger"              echo 
                echo "Visit http://www.sql-ledger-network.com for more information on SQL-Ledger"
                echo "Visit http://forum.sql-ledger-network.com for support"
                echo "Suggestions for improvement and other feedback can be emailed to 'info@sql-ledger-network.com'. Thanks!"
                echo
                echo "IMPORTANT NOTE: This simple installation was designed to be run only on the local network."
fi
exit 0
