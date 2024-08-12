#####################################################
# Lanchon REPIT - Device Handler                    #
# Copyright 2016, Lanchon                           #
#####################################################

#####################################################
# Lanchon REPIT is free software licensed under     #
# the GNU General Public License (GPL) version 3    #
# and any later version.                            #
#####################################################

### galaxy-a2-core

# Model: MMC AJTD4R (sd/mmc)
# Disk /dev/block/mmcblk0: 15028MiB
# Sector size (logical/physical): 512B/512B
# Partition Table: gpt

# Number  Start     End       Size      File system  Name        Flags
#         0.02MiB   4.00MiB   3.98MiB   Free Space
# 1       4.00MiB   8.00MiB   4.00MiB                BOTA0
# 2       8.00MiB   12.0MiB   4.00MiB                BOTA1
# 3       12.0MiB   32.0MiB   20.0MiB   ext4         EFS
# 4       32.0MiB   40.0MiB   8.00MiB                CPEFS
# 5       40.0MiB   44.0MiB   4.00MiB                m9kefs1
# 6       44.0MiB   48.0MiB   4.00MiB                m9kefs2
# 7       48.0MiB   52.0MiB   4.00MiB                m9kefs3
# 8       52.0MiB   53.0MiB   1.00MiB                NAD_REFER
# 9       53.0MiB   61.0MiB   8.00MiB                PARAM
# 10      61.0MiB   93.0MiB   32.0MiB                BOOT
# 11      93.0MiB   131MiB    38.0MiB                RECOVERY
# 12      131MiB    219MiB    88.0MiB                RADIO
# 13      219MiB    219MiB    0.50MiB                PERSISTENT
# 14      220MiB    223MiB    4.00MiB                STEADY
# 15      224MiB    224MiB    1.00MiB                MISC
# 16      225MiB    226MiB    2.00MiB                DTBO
# 17      227MiB    232MiB    5.50MiB                RESERVED2
# 18      232MiB    1576MiB   1344MiB   ext4         SYSTEM
# 19      1576MiB   1752MiB   176MiB    ext4         VENDOR
# 20      1752MiB   1800MiB   48.0MiB   ext4         ODM
# 21      1800MiB   1840MiB   40.0MiB   ext4         CACHE
# 22      1840MiB   1857MiB   17.0MiB   ext4         HIDDEN
# 23      1857MiB   1881MiB   24.0MiB   ext4         OMR
# 24      1881MiB   1886MiB   5.00MiB                CP_DEBUG
# 25      1886MiB   1906MiB   20.0MiB                NAD_FW
# 26      1906MiB   15022MiB  13116MiB               USERDATA
#         15022MiB  15028MiB  5.98MiB   Free Space


device_makeFlashizeEnv="env/arm.zip"

device_makeFilenameConfig="system=1G-cache=32M+wipe-preload=min+wipe-data=max"

device_init() {

    device_checkDevice

    # the block device on which REPIT will operate (only one device is supported):

    #sdev=/sys/devices/soc.0/13540000.dwmmc0/mmc_host/mmc0/mmc0:0001/block/mmcblk0
    sdev=/sys/block/mmcblk0
    spar=$sdev/mmcblk0p

    ddev=/dev/block/mmcblk0
    dpar=/dev/block/mmcblk0p

    sectorSize=512      # in bytes

    # a grep pattern matching the partitions that must be unmounted before REPIT can start:
    #unmountPattern="${dpar}[0-9]\+"
    unmountPattern="/dev/block/mmcblk[^ ]*"

}

device_initPartitions() {

    # the crypto footer size:
    local footerSize=$(( 20480 / sectorSize ))

    # the set of partitions that can be modified by REPIT:
    #     <gpt-number>  <gpt-name>  <friendly-name> <conf-defaults>     <crypto-footer>
    initPartition   18  SYSTEM      system          "same keep ext4"    0
    initPartition   19  VENDOR      vendor          "same keep ext4"    0
    initPartition   20  ODM         odm             "same keep ext4"    0
    initPartition   21  CACHE       cache           "same keep ext4"    0
    initPartition   22  HIDDEN      preload         "same keep ext4"    0
    initpartition   23  OMR         omr             "same keep ext4"    0
    initpartition   24  CP_DEBUG    cp_debug        "same keep raw"     0
    initpartition   25  NAD_FW      nad_fw          "same keep raw"     0
    initPartition   26  USERDATA    data            "same keep f2fs"    $footerSize

    # the set of modifiable partitions that can be configured by the user (overriding <conf-defaults>):
    configurablePartitions="$(seq 18 26)"

}

device_setup() {

    # the number of partitions that the device must have:
    partitionCount=26

    # the set of defined heaps:
    allHeaps="main"

    # the partition data move chunk size (must fit in memory):
    moveDataChunkSize=$(( 256 * MiB ))

    # only call this if you will later use $deviceHeapStart or $deviceHeapEnd:
    detectBlockDeviceHeapRange

    # the size of partitions configured with the 'min' keyword:
    #heapMinSize=$(( 8 * MiB ))
    
    # the partition alignment:
    heapAlignment=$(( 4 * MiB ))

}

device_setupHeap_main() {

    # the set of contiguous partitions that form this heap, in order of ascending partition start address:
    heapPartitions="$(seq 25 28)"

    # the disk area (as a sector range) to use for the heap partitions:
    heapStart=$(parOldEnd 17)       # one past the end of a specific partition
    heapEnd=$deviceHeapEnd          # one past the last usable sector of the device

}
