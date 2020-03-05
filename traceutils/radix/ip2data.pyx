from traceutils.file2.file2 cimport File2
from traceutils.radix.radix cimport Radix
from traceutils.radix.radix_node cimport RadixNodeData
from traceutils.radix.radix_tree cimport RadixTreeData
from libc.stdlib cimport atol

cdef list PRIVATE4 = ['0.0.0.0/8', '10.0.0.8/8', '100.64.0.0/10', '127.0.0.0/8', '169.254.0.0/16', '172.16.0.0/12',
            '192.0.0.0/24', '192.0.2.0/24', '192.31.196.0/24', '192.52.193.0/24', '192.88.99.0/24', '192.168.0.0/16',
            '192.175.48.0/24', '198.18.0.0/15', '198.51.100.0/24', '203.0.113.0/24', '240.0.0.0/4',
            '255.255.255.255/32']
cdef list PRIVATE6 = ['::1/128', '::/128', '::ffff:0:0/96', '64:ff9b::/96', '100::/64', '2001::/23', '2001::/32', '2001:1::1/128',
            '2001:2::/48', '2001:3::/32', '2001:4:112::/48', '2001:5::/32', '2001:10::/28', '2001:20::/28',
            '2001:db8::/32', '2002::/16', '2620:4f:8000::/48', 'fc00::/7', 'fe80::/10']
cdef str MULTICAST4 = '224.0.0.0/3'
cdef str MULTICAST6 = 'FF00::/8'

cdef class IP2Data(Radix):

    def __init__(self):
        tree4 = RadixTreeData()
        tree6 = RadixTreeData()
        super().__init__(tree4, tree6)

    def __getitem__(self, str item):
        return self.data(item)

    cpdef RadixNodeData add_data(self, str network, short masklen=-1, dict data=None):
        cdef RadixNodeData node = self.add(network, masklen)
        if data is not None:
            node.data.update(data)
        return node

    cpdef dict data(self, str addr):
        cdef RadixNodeData node = self.search_best(addr)
        if node:
            return node.data
        return {}

    cpdef dict data_packed(self, bytes packed):
        cdef RadixNodeData node = self.search_best_packed(packed, -1)
        if node:
            return node.data
        return {}

    cpdef void add_private(self) except *:
        cdef dict data = {'asn': -1}
        for prefix in PRIVATE4:
            self.add_data(prefix, -1, data)
        for prefix in PRIVATE6:
            self.add_data(prefix, -1, data)
        self.add_data(MULTICAST4, -1, data)
        self.add_data(MULTICAST6, -1, data)


cpdef IP2Data create_private():
    cdef IP2Data ip2as = IP2Data()
    ip2as.add_private()
    return ip2as


cpdef IP2Data create_table(str filename):
    cdef IP2Data ip2as
    cdef bytes prefix, asn_str
    cdef long asn
    cdef str prefix_s
    ip2as = IP2Data()
    with File2(filename, 'rb') as f:
        # f.readline()
        for line in f:
            prefix, asn_str = line.rstrip().split()
            asn = atol(asn_str)
            prefix_s = prefix.decode()
            ip2as.add_data(prefix_s, -1, data={'asn': asn})
    return ip2as
