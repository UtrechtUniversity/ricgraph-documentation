<img alt="Ricgraph logo" src="https://raw.githubusercontent.com/UtrechtUniversity/ricgraph/refs/heads/main/docs/images/ricgraph_logo.png" height="30">

# Documentation for Ricgraph - Research in context graph

This repository contains the files for the
documentation for Ricgraph – Research in context graph.
To learn more about
Ricgraph, go to its 
[Ricgraph GitHub repository](https://github.com/UtrechtUniversity/ricgraph),
or to its website
[www.ricgraph.eu](https://www.ricgraph.eu).

You can generate three "targets":

* the Documentation website for Ricgraph,
  [https://documentation.ricgraph.eu](https://documentation.ricgraph.eu);
* the Tutorial for Ricgraph,
  [https://documentation.ricgraph.eu/ricgraph-tutorial.pdf](https://documentation.ricgraph.eu/ricgraph-tutorial.pdf);
* the Full documentation for Ricgraph,
  [https://documentation.ricgraph.eu/ricgraph-fulldocumentation.pdf](https://documentation.ricgraph.eu/ricgraph-fulldocumentation.pdf).


The documentation for Ricgraph is generated using
[Quarto](https://www.quarto.org)
from the documentation in the
[Ricgraph GitHub repository](https://github.com/UtrechtUniversity/ricgraph).

## Ricgraph documentation Makefile
To generate the targets above, create a distribution `tar.gz` file, and install it
on a webserver, a [Makefile](https://www.gnu.org/software/make) is used.
Such a Makefile automates a number of steps.
A Makefile command is executed by typing:
```
make [target]
```
In the example above, the *[target]* specifies what has to be done.
Assuming that you are in your home directory, you can
execute one of these commands to find the possible targets
(and subsequently find the command to build the documentation targets above):
```
make
make help
```


## Generate documentation and create a distribution file

* Find the version number of the most recent released version of the documentation
  in directory
  [https://github.com/UtrechtUniversity/ricgraph-documentation/releases](https://github.com/UtrechtUniversity/ricgraph-documentation/releases).
* Get the file, type:
  ```
  cd
  wget https://github.com/UtrechtUniversity/ricgraph-documentation/archive/refs/tags/[version number].tar.gz
  tar xf [version number].tar.gz
  cd ricgraph-documentation-[version number]
  ```
* Download the most recent version of the Makefile. Type:
  ```
  cd
  wget https://raw.githubusercontent.com/UtrechtUniversity/ricgraph-documentation/main/Makefile
  ```
* Type the following command to find the possible targets:
  ```
  make
  make help
  ```
* Build the documentation using one or more of the available Makefile targets.
* Go to your webserver and install the documentation (read the next section).


## Install the documentation distribution file on a webserver

* Go to your home directory on the Linux webserver, and
  download the most recent version of the Makefile from the GitHub repository. Type:
  ```
  cd
  wget https://raw.githubusercontent.com/UtrechtUniversity/ricgraph-documentation/main/Makefile
  ```
* Find the version number of the most recent version of the documentation
  in directory 
  [https://github.com/UtrechtUniversity/ricgraph-documentation/tree/main/distrib-documentation](https://github.com/UtrechtUniversity/ricgraph-documentation/tree/main/distrib-documentation).
* Install the documentation, type:
  ```
  sudo bash
  make ricgraph_version=[version number without v] install_documentation_website
  exit
  ```
* Done.


## Configuration Apache webserver for Ricgraph documentation website
To show the documentation website for Ricgraph, you will need a machine with a webserver.
This section describes how to create a 
[VirtualHost](https://en.wikipedia.org/wiki/Virtual_hosting) for the 
[Apache webserver](https://httpd.apache.org).
A sample configuration file can be found in directory
*server_config*.
Note that different Linux editions use different paths: 

* OpenSUSE Leap: `apache2` and /etc/apache2/vhosts.d
* Ubuntu: `apache2` and /etc/apache/sites-available
* Fedora: `httpd` and /etc/httpd/conf.d

In the steps below, path names from
OpenSUSE Leap are used. Please adapt them to you own Linux edition.
Configure Apache as follows:

* Login as user *root*.
* Make sure Apache has been installed.
* Enable two Apache modules (they have already been installed when you installed Apache):
  ```
  a2enmod mod_ssl
  a2enmod mod_rewrite
  ```
* Make sure Certbot has been installed.
* Install the Apache configuration file for the Ricgraph documentation website:
  copy file
  *server_config/documentation-ricgraph-eu.conf-template-apache2*
  to /etc/apache2/vhosts.d and rename it, type:
  ```
  cp ricgraph_server_config/documentation-ricgraph-eu.conf-template-apache2 /etc/apache2/vhosts.d/documentation-ricgraph-eu.conf
  chmod 600 /etc/apache2/vhosts.d/documentation-ricgraph-eu.conf
  ```
  This file assumes that
  [https://documentation.ricgraph.eu](https://documentation.ricgraph.eu)
  will be hosting the Ricgraph documentation files.
  Change this file in such a way it fits your situation.
* Depending on you situation:
  * In case you are installing the first website (VirtualHost)
    on this machine, enable and start Apache, type:
    ``` 
    systemctl enable apache2.service
    systemctl start apache2.service
    ```
  * In case you are already hosting other websites (VirtualHosts)
    on this machine, restart Apache, type:
    ```
    systemctl restart apache2
    ```
  * Check the log for any errors, use one of:
    ```
    systemctl -l status apache2.service
    journalctl -u apache2.service
    ```
* Request a certbot certificate, type:
  ```
  certbot --apache -d documentation.ricgraph.eu
  ```
* Enable SSL in the config file. With your favorite text editor, in the config file
  *documentation-ricgraph-eu.conf*, change line:
  ```
  #SSLEngine on
  ```
  to
  ```
  SSLEngine on
  ```
* Restart Apache:  
  ```
  systemctl restart apache2
  ```
* Exit from user *root*.
* In your web browser, go to
  [https://documentation.ricgraph.eu](https://documentation.ricgraph.eu).
