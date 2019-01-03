from traceutils.file2.file2 cimport File2
from traceutils.radix.radix cimport Radix
from traceutils.radix.radix_node cimport RadixNode
from libc.stdlib cimport atol

cdef class IP2AS(Radix):

    def __getitem__(self, str item):
        return self.asn(item)

    cpdef long asn(self, str addr):
        cdef RadixNode node = self.search_best(addr)
        if node:
            return node.asn
        return 0

cpdef IP2AS create_table(str filename):
    cdef IP2AS ip2as
    cdef bytes prefix, asn_str
    cdef long asn
    cdef str prefix_s
    ip2as = IP2AS()
    with File2(filename, 'rb') as f:
        f.readline()
        for line in f:
            prefix, asn_str = line.rstrip().split(b',')
            asn = atol(asn_str)
            prefix_s = prefix.decode()
            ip2as.add(prefix_s, -1, asn=asn)
    return ip2as
