from traceutils.radix.radix cimport Radix


cdef list PRIVATE4, PRIVATE6
cdef str MULTICAST4, MULTICAST6


cdef class IP2AS(Radix):
    cpdef long asn(self, str asn);
    cpdef long asn_packed(self, bytes packed);
    cpdef void add_private(self) except *

cpdef IP2AS create_private();
cpdef IP2AS create_table(str filename);
