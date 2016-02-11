##HBase

[![Build Status](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-hbase.svg?branch=master)](https://travis-ci.org/MetaCenterCloudPuppet/cesnet-hbase)

####Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with HBase](#setup)
    * [What cesnet-hbase module affects](#what-hbase-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hbase](#beginning-with-hbase)
3. [Usage - Configuration options and additional functionality](#usage)
    * [HBase REST and Thrift API](#apis)
    * [Enable HTTPS](#https)
    * [Multihome Support](#multihome)
    * [High Availability](#ha)
    * [Cluster with more HDFS Name nodes](#multinn)
    * [Upgrade](#upgrade)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Parameters (hbase class)](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="module-description"></a>
##Module Description

This module installs and setups HBase Cluster, with all services collocated or separated across all nodes or single node as needed. Optionally other features can be enabled:

* the security based on Kerberos

Supported are:

* **Fedora**: native packages (tested on HBase 0.98.3)
* **Debian 7/wheezy**: Cloudera distribution (tested on HBase 0.98.6)
* **RHEL 6 and clones**: Cloudera distribution (tested on HBase 1.0.0)

Puppet 3.x is required.

<a name="setup"></a>
##Setup

<a name="what-hbase-affects"></a>
###What cesnet-hbase module affects

* Packages: installs HBase packages (subsets for requested services, or the client)
* Files modified:
 * /etc/hbase/\* (or /etc/hbase/conf/\*)
 * /etc/cron.d/hbase-\* (only when explicit key refresh or restarts are requested)
 * /usr/local/sbin/hbmanager (not needed, only when administrator manager script is requested by *features*)
* Alternatives:
 * alternatives are used for /etc/hbase/conf in Cloudera
 * this module switches to the new alternative by default, so the Cloudera original configuration can be kept intact
* Services:
 * master (main server, backup servers)
 * regionserver (slaves)
 * internal zookeeper (quorum) - not in all distributions, better to use external zookeeper
* Helper Files:
 * /var/lib/hadoop-hdfs/.puppet-hbase-dir-created
* Secret Files (keytabs): some files are copied to home directory of service user: ~hbase

<a name="setup-requirements"></a>
###Setup Requirements

There are several known or intended limitations in this module.

Be aware of:

* **repositories**: No new repository is set up, see cesnet-hadoop module for details.

* **secure mode**: Keytabs must be prepared in /etc/security/keytabs/ (see *realm* parameter).

* **https**: The files prepared for Hadoop are needed also here.
 * /etc/security/http-auth-signature-secret file (with any content)
 * /etc/security/keytab/http.service.keytab

   Note: the files are copied into ~hbase.

* **inter-node dependencies**: Hadoop cluster (the HDFS part) needs to be deployed and running before launching HBase. You should add dependencies on *hadoop::namenode::service* and *hadoop::datanode::service*, if possible (for collocated services) or choose other way (let's fail first puppet launch, use PuppetDB, ...).

* **zookeeper**: Some versions of HBase provides internal zookeeper, but external zookeeper is recommended. You can use cesnet-zookeeper puppet module.

<a name="beginning-with-hbase"></a>
###Beginning with hbase

By default the main *hbase* class do nothing but configuration of the hbase puppet module. Main actions are performed by the included service and client classes.

Let's start with brief examples.

**Example**: The simplest setup is one-node HBase cluster without security, with everything on single machine:

    class{'hbase':
      hdfs_hostname => $::fqdn,
      master_hostname => $::fqdn,
      zookeeper_hostnames => [ $::fqdn ],
      external_zookeeper => true,
      slaves => [ $::fqdn ],
      frontends => [ $::fqdn ],
      realm => '',
      features => {
        hbmanager => true,
      },
    }
    
    node default {
      include stdlib
    
      include hbase::master
      include hbase::regionserver
      include hbase::frontend
      include hbase::hdfs
    
      class{'zookeeper':
        hostnames => [ $::fqdn ],
        realm => '',
      }
     
      Class['hadoop::namenode::service'] -> Class['hbase::hdfs']
      Class['hadoop::namenode::service'] -> Class['hbase::master::service']
    }

In this example the Hadoop cluster part is missing, see cesnet-hadoop puppet module. Modify $::fqdn and node(s) section as needed.

<a name="usage"></a>
##Usage

<a name="apis"></a>
### HBase REST and Thrift API

REST and Thrift daemons have issues when using in secured environment:

 * HBase REST doesn't support HTTPS
 * HBase Thrift supports SSL, but there is problematic support in thrift clients
 * HBase Thrift has security problems (each access translated to *hbase* identity)

When using HBase REST with Kerberos (SPNEGO), the credentials should not leak out. But still, Man-In-Middle can steal session until next renegotiation (default 1 hour).

**Example Rest**: HBase REST Server (modify *$::fqdn* and *default* to proper values):

    class{'hbase':
      ...
      # (needed only for helper admin script hbmanager)
      rest_hostnames => [ $::fqdn ],
      ...
    }

    node default {
      ...
      include hbase::rest
    }

**Example Thrift**: HBase Thrift Server (modify *$::fqdn* and *default* to proper values):

    class{'hbase':
      ...
      # (needed only for helper admin script hbmanager)
      thrift_hostnames => [ $::fqdn ],
      ...
    }

    node default {
      ...
      include hbase::thrift
    }

<a name="https"></a>
###Enable HTTPS

Hadoop and also HBase is able to use SPNEGO protocol (="Kerberos tickets through HTTPS"). This requires proper configuration of the browser on the client side and valid Kerberos ticket.

HTTPS support requires:

* enabled security (*realm* => ...)
  * configured Kerberos (/etc/krb5.conf, /etc/krb5.keytab)
  * /etc/security/keytab/hbase.service.keytab
  * enabled security on HDFS
  * enabled security on zookeeper, if external
* /etc/security/cacerts file (*https_cacerts* parameter) - kept in the place, only permission changed if needed
* /etc/security/server.keystore file (*https_keystore* parameter) - copied for each daemon user
* /etc/security/http-auth-signature-secret file (any data, string or blob) - copied for each daemon user
* /etc/security/keytab/http.service.keytab - copied for each daemon user

All files should be available already from installing of Hadoop cluster, no additional files are needed. See cesnet-hadoop puppet module documentation for details.

The following hbase class parameters are used for HTTPS (see also [Parameters](#parameters)):

 * *realm* (required for HTTPS) Enable security and Kerberos realm to use.
 * *https* (undef) Enable support for https.
 * *https_keystore* (/etc/security/server.keystore) Certificates keystore file.
 * *https_keystore_password* (changeit) Certificates keystore file password.
 * *https_keystore_keypassword* (undef) Certificates keystore key password.
 * *acl* (undef) If setfacl command is available. *acl* parameter needs to be enabled, if is it enabled also for Hadoop cluster in cesnet-hadoop puppet module.

<a name="multihome"></a>
###Multihome Support

There is only limited support of HBase on multiple interfaces (2015-01). Web UI access works fine, but the master and regionserver services listen only on the primary IP address.

It can be worked around. For example using NAT.

**Example NAT**: Have this /etc/hosts file:

    127.0.0.1       localhost
    
    10.2.4.12	hador-c1.ics.muni.cz	hador-c1
    147.251.9.38	hador-c1.ics.muni.cz	hador-c1

In this case the HBase will listen on the interface with 10.2.4.12 IP address. If we want to add access from external network 147.251.9.38 using NAT:

    # master, backup masters
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60000 -j DNAT --to-destination 10.2.4.12:60000
    # regionservers
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60020 -j DNAT --to-destination 10.2.4.12:60020

NAT works OK also with security enabled, you may need *noaddresses = yes* in */etc/krb5.conf*.

<a name="ha"></a>
###High Availability

For HBase Master high availability you need to include class *hbase::master* on multiple nodes, put the main HBase Master into *master_hostname* parameter, and all other into *backup_hostnames* parameter as an array:

    class{'hbase':
      ...
      master_hostname  => $hbase_master1,
      backup_hostnames => [$hbase_master2],
      ...
    }

    node $hbase_master1 {
      include ::hbase::master
    }

    node $hbase_master2 {
      include ::hbase::master
    }

<a name="multinn"></a>
###Cluster with more HDFS Name nodes

If there are used more HDFS namenodes in the Hadoop cluster (high availability, namespaces, ...), it is needed to have 'hbase' system user on all of them to authorization work properly. You could install full HBase client (using *hbase::frontend::install*), but just creating the user is enough (using *hbase::user*).

Note, the *hbase::hdfs* class must be used too, but only on one of the HDFS namenodes. It includes the *hbase::user*.

**Example**:

    node <HDFS_NAMENODE> {
      include hbase::hdfs
    }

    node <HDFS_OTHER_NAMENODE> {
      include hbase::user
    }

<a name="upgrade"></a>
###Upgrade

The best way is to refresh configurations from the new original (=remove the old) and relaunch puppet on top of it. You may need to remove helper file *~hbase/.puppet-ssl\**, when upgrading from older versions of cesnet-hbase module.

For example:

    alternative='cluster'
    d='hbase'
    mv /etc/{d}$/conf.${alternative} /etc/${d}/conf.cdhXXX
    update-alternatives --auto ${d}-conf
    rm -fv ~hbase/.puppet-ssl*

    # upgrade
    ...

    puppet agent --test
    #or: puppet apply ...

<a name="reference"></a>
##Reference

<a name="classes"></a>
###Classes

* [**`hbase`**](#class-hbase): HBase Cluster setup
* `hbase::config`
* `hbase::install`
* `hbase::params`
* `hbase::service`
* `hbase::common::daemons::config`
* `hbase::common::config`
* `hbase::common::keytab`
* `hbase::common::postinstall`
* **`hbase::frontend`**: HBase client
* `hbase::frontend::config`
* `hbase::frontend::install`
* **`hbase::hdfs`**: HBase initialization on HDFS
* **`hbase::master`**: HBase master
* `hbase::master::config`
* `hbase::master::install`
* `hbase::master::service`
* **`hbase::regionserver`**: HBase worker node
* `hbase::regionserver::config`
* `hbase::regionserver::install`
* `hbase::regionserver::service`
* **`hbase::restserver`**: HBase REST Server
* `hbase::restserver::config`
* `hbase::restserver::install`
* `hbase::restserver::service`
* **`hbase::thriftserver`**: HBase Thrift Server
* `hbase::thriftserver::config`
* `hbase::thriftserver::install`
* `hbase::thriftserver::service`
* **`hbase::user`**: Create HBase system user, if needed
* **`hbase::zookeeper`**: HBase internal zookeeper (recommended external zookeeper instead)
* `hbase::zookeeper::config`
* `hbase::zookeeper::install`
* `hbase::zookeeper::service`

<a name="class-hbase"></a>
<a name="parameters"></a>
###`hbase` class parameters

####`backup_hostnames`

Hostnames of all backup masters. Default: undef.

####`hdfs_hostname`

Main node of Hadoop (HDFS Name Node) (required).

Used to launch 'hdfs dfs' commands there.

####`master_hostname`

HBase master node. Default: undef.

####`rest_hostnames`

Rest Server hostnames (used only for the helper admin script). Default: undef.

####`thrift_hostnames`

Thrift Server hostnames (used only for the helper admin script). Default: undef.

####`zookeeper_hostnames`

Zookeepers to use (required).

May be ["localhost"] in non-cluster mode.

####`external_zookeeper`

Don't launch HBase Zookeeper. Default: true.

####`slaves`

HBase regionserver nodes. Default: [].

####`frontends`

Array of frontend hostnames. Default: [].

####`realm`

Kerberos realm, or empty string to disable security. Default: ''.

To enable security, there are required:

* configured Kerberos (*/etc/krb5.conf*, */etc/krb5.keytab*)
* */etc/security/keytab/hbase.service.keytab*
* enabled security on HDFS
* enabled security on zookeeper, if external

####`descriptions`

Descriptions for the properties. Default: see params.pp.

Just for cuteness.

####`features`

Default: ().

List of features:

* restarts
* hbmanager

####`acl`

Set to true, if setfacl command is available and */etc/hadoop* is on filesystem supporting POSIX ACL. Default: undef.

It is used to set privileges of *ssl-server.xml* for HBase. If the POSIX ACL is not supported, disable this parameter also in cesnet-hadoop puppet module.

####`alternatives`

Switches the alternatives used for the configuration. Default: 'cluster' (Debian) or undef.

It can be used only when supported (for example with Cloudera distribution).

####`group`

User groups. Default: 'users'.

Used for REST server and Thrift server impersonation.

####`https`

Enable https support. Default: undef.

It needs to be set when Hadoop cluster has https enabled.

* **true**: enable https
* **hdfs**: enable https only for Hadoop, keep HBase https disabled
* **false**: disable https

####`https_keystore`

Certificates keystore file (for thrift server). Default: '/etc/security/server.keystore'.

####`https_keystore_password`

Certificates keystore file password (for thrift server). Default: 'changeit'.

####`https_keystore_keypassword`

Certificates keystore key password (for thrift server). Default: undef.

If not specified, *https\_keystore\_password* is used.

####`properties`

Default: undef.

<a name="limitations"></a>
##Limitations

See [Setup Requirements](#setup-requirements) section.

<a name="development"></a>
##Development

* Repository: [https://github.com/MetaCenterCloudPuppet/cesnet-hbase.git](https://github.com/MetaCenterCloudPuppet/cesnet-hbase.git)
* Tests:
 * basic: see *.travis.yml*
 * vagrant: [https://github.com/MetaCenterCloudPuppet/hadoop-tests](https://github.com/MetaCenterCloudPuppet/hadoop-tests)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
