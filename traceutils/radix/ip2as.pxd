from traceutils.radix.radix cimport Radix

cdef class IP2AS(Radix):
    cpdef long asn(self, str asn);

cpdef IP2AS create_table(str filename);
