```

1、选择存储驱动的整体考虑

对于选择哪些那一个存储驱动时，综合可以考虑下面的因素：

优先级：如果内核中支持多个存储驱动程序，则在未明确配置任何存储驱动程序的情况下，Docker会从优先列表中选择所使用的存储驱动程序。


性能和稳定性：根据业务应用的情况，综合考虑稳定性和性能要求。
宿主机支持：依据宿主机机的操作系统版本，选择合适的存储驱动。在当前，Docker支持以下存储驱动程序：
–overlay2： 当前所有受支持Linux发行版的首选存储驱动程序，不需要进行任何额外的配置。

–aufs：在Ubuntu 14.04（内核3.13）上运行的Docker 18.06及更早版本的首选存储驱动程序。

–devicemapper：devicemapper是CentOS和RHEL推荐的存储驱动程序，因为它们的内核版本不支持overlay2。但是，当前版本的CentOS和RHEL已经支持overlay2，overlay成为了推荐的驱动程序。

–btrfs或zfs：这些文件系统允许使用高级选项，例如创建“快照”，但需要更多的维护和设置。它们都赖于正确配置的后备文件系统。

–vfs：此存储驱动程序用于测试目的，以及在无法使用写时复制文件系统的情。此存储驱动程序的性能很差，通常不建议在生产中环境中进行使用。


apfs
tmpfs



性能考虑

每个存储驱动程序都有其自己的性能特征，这使其或多或少地适合于不同的工作负载。考虑以下概括：

overlay2，aufs和overlay都是在文件级别而不是块级别运行的。这样可以更有效地使用内存，但是在写繁重的工作负载中，容器的可写层可能会变得非常大。
devicemapper，btrfs和zfs都是块存储驱动器，它们能够更好地承担写繁重的工作。
对于许多小型写入或具有多层或深文件系统的容器， overlay的性能可能比overlay2更好。但会消耗更多的inode，这可能导致inode耗尽。
btrfs和zfs需要使用大量的内存。
zfs 对于高密度工作负载（如PaaS）是一个不错的选择。

匿名页  缓存

清除页面缓存

echo 1 > /proc/sys/vm/drop_caches 

建立动态路由需要用到的文件有 /etc/gateways

AIX https://www.ibm.com/support/knowledgecenter/en/ssw_aix_71/filesreference/gateways.html

```
