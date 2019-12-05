from traceutils.file2.file2 cimport File2
from traceutils.radix.radix cimport Radix
from traceutils.radix.radix_node cimport RadixNodeASNs
from traceutils.radix.radix_tree cimport RadixTreeASNs
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

cdef class IP2ASes(Radix):

    def __init__(self):
        tree4 = RadixTreeASNs()
        tree6 = RadixTreeASNs()
        super().__init__(tree4, tree6)

    def __getitem__(self, str item):
        return self.asns(item)

    cpdef RadixNodeASNs add_asns(self, str network, short masklen=-1, list asns=None):
        cdef RadixNodeASNs node = self.add(network, masklen)
        node.asns = asns
        return node

    cpdef list asns(self, str addr):
        cdef RadixNodeASNs node = self.search_best(addr)
        if node:
            return node.asns
        return []

    cpdef list asns_packed(self, bytes packed):
        cdef RadixNodeASNs node = self.search_best_packed(packed, -1)
        if node:
            return node.asns
        return 0

    cpdef void add_private(self) except *:
        for prefix in PRIVATE4:
            self.add_asns(prefix, -1, [-1])
        for prefix in PRIVATE6:
            self.add_asns(prefix, -1, [-1])
        self.add_asns(MULTICAST4, -1, [-1])
        self.add_asns(MULTICAST6, -1, [-1])


cpdef IP2ASes create_private():
    cdef IP2ASes ip2as = IP2ASes()
    ip2as.add_private()
    return ip2as


cpdef IP2ASes create_table(str filename):
    cdef bytes prefix, asns_str, asn_str
    cdef long asn
    cdef str prefix_s
    cdef list asns
    cdef IP2ASes ip2as = IP2ASes()
    with File2(filename, 'rb') as f:
        # f.readline()
        for line in f:
            asns = []
            prefix, asns_str = line.rstrip().split()
            for asn_str in asns_str.split(b','):
                asn = atol(asn_str)
                asns.append(asn)
            prefix_s = prefix.decode()
            ip2as.add_asns(prefix_s, -1, asns=asns)
    return ip2as
