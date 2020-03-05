from traceutils.radix.radix cimport Radix
from traceutils.radix.radix_node cimport RadixNodeData


cdef list PRIVATE4, PRIVATE6
cdef str MULTICAST4, MULTICAST6


cdef class IP2Data(Radix):
    cpdef RadixNodeData add_data(self, str network, short masklen=*, dict data=*);
    cpdef dict data(self, str asn);
    cpdef dict data_packed(self, bytes packed);
    cpdef void add_private(self) except *

cpdef IP2Data create_private();
cpdef IP2Data create_table(str filename);
