####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with HBase](#setup)
    * [What cesnet-hbase module affects](#what-hbase-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hbase](#beginning-with-hbase)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Multihome Support](#multihome)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Parameters](#parameters)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

<a name="overview"></a>
##Overview

Management of HBase Cluster with security based on Kerberos. Puppet 3.x is required. Supported and tested are Fedora (native Hadoop) and Debian (Cloudera distribution).

<a name="module-description"></a>
##Module Description

This module installs and setups HBase Cluster, with all services collocated or separated across all nodes or single node as needed. Optionally other features can be enabled:

* the security based on Kerberos

Supported are:

* Fedora 21: native packages (tested on HBase 0.98.3)
* Debian 7/wheezy: Cloudera distribution (tested on HBase 0.98.6)

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
 * master (main server)
 * regionserver (slaves)
 * internal zookeeper (quorum) - not in all distributions, better to use external zookeper
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

* **inter-node dependencies**: Hadoop cluster (the HDFS part) needs to be deployed and running before lauching HBase. You should add dependencies on *hadoop::namenode::service* and *hadoop::datanode::service*, if possible (for collocated services) or choose other way (let's fail first puppet launch, use PuppetDB, ...).

* **zookeeper**: Some versions of HBase provides internal zookeeper, but external zookeeper is recommended. You can use cesnet-zookeeper puppet module.

<a name="beginning-with-hbase"></a>
###Beginning with hbase

By default the main *hbase* class do nothing but configuration of the hbase puppet module. Main actions are performed by the included service and client classes.

Let's start with brief examples.

**Example 1**: The simplest setup is one-node HBase cluster without security, with everything on single machine:

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

TODO: Put the classes, types, and resources for customizing, configuring, and doing the fancy stuff with your module here.

<a name="multihome"></a>
###Multihome Support

There is only limited support of HBase on multiple interfaces (2015-01). Web UI access works fine, but the master and regionserver services listen only on the primary IP address.

It can be worked around. For example using NAT.

**Example NAT**: Have this /etc/hosts file:

    127.0.0.1       localhost
    
    10.2.4.12	hador-c1.ics.muni.cz	hador-c1
    147.251.9.38	hador-c1.ics.muni.cz	hador-c1

In this case the HBase will listen on the interface with 10.2.4.12 IP address. If we want to add access from external network 147.251.9.38 using NAT:

    # master
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60000 -j DNAT --to-destination 10.2.4.12:60000
    # regionservers
    iptables -t nat -A PREROUTING -p tcp -m tcp -d 147.251.9.38 --dport 60020 -j DNAT --to-destination 10.2.4.12:60020

NAT works OK also with enabled security.

<a name="reference"></a>
##Reference

<a name="classes"></a>
###Classes

* config
* install
* init
* params
* service
* common:
 * daemons:
  * config
 * config
 * keytab
 * postinstall
* **frontend** - HBase client
 * config
 * install
* **hdfs** - HBase initialization on HDFS
* **master** - HBase master
 * config
 * install
 * service
* **regionserver** - HBase worker node
 * config
 * install
 * service
* **zookeeper** - HBase internal zookeeper (recommended external zookeeper instead)
 * config
 * install
 * service

<a name="parameters"></a>
###Parameters

[*hdfs_hostname*] required

  Main node of Hadoop (HDFS Name Node). Used for launching 'hdfs dfs' commands there.

[*master_hostname*] (undef)

  HBase master node.

[*zookeeper_hostnames*] required

  Zookeepers to use. May be ["localhost"] in non-cluster mode.

[*external_zookeeper*] (false)

  Don't launch HBase Zookeeper.

[*slaves*] ([])

  HBase regionserver nodes.

[*frontends*] ([])

  Array of frontend hostnames. Package and configuration is needed on frontends.

[*realm*] required

  Kerberos realm, or empty string to disable security.
  To enable security, there are required:

 * configured Kerberos (/etc/krb5.conf, /etc/krb5.keytab)
 * /etc/security/keytab/hbase.service.keytab
 * enabled security on HDFS
 * enabled security on zookeeper, if external

[*properties*]

[*descriptions*]

[*features*]

 * restarts
 * hbmanager

[*https*] undef
  Enable https support. It needs to be set when Hadoop cluster has https enabled.

 * **true**: enable https
 * **hdfs**: enable https only for Hadoop, keep HBase https disables
 * **false**: disable https

<a name="limitations"></a>
##Limitations

See [Setup Requirements](#setup-requirements) section.

<a name="development"></a>
##Development

* Repository: [http://scientific.zcu.cz/git/?p=cesnet-hbase.git;a=summary](http://scientific.zcu.cz/git/?p=cesnet-hbase.git;a=summary)
* Email: František Dvořák &lt;valtri@civ.zcu.cz&gt;
