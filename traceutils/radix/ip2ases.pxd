from traceutils.radix.radix cimport Radix
from traceutils.radix.radix_node cimport RadixNodeASNs


cdef list PRIVATE4, PRIVATE6
cdef str MULTICAST4, MULTICAST6


cdef class IP2ASes(Radix):
    cpdef RadixNodeASNs add_asns(self, str network, short masklen=*, list asns=*);
    cpdef list asns(self, str asn);
    cpdef list asns_packed(self, bytes packed);
    cpdef void add_private(self) except *

cpdef IP2ASes create_private();
cpdef IP2ASes create_table(str filename);
