from traceutils.radix.radix_prefix cimport RadixPrefix

cdef class RadixNode:
    cdef public RadixPrefix prefix
    cdef RadixNode parent, left, right
    cdef public unsigned char bitlen

cdef class RadixNodeASN(RadixNode):
    cdef public int asn

cdef class RadixNodeASNs(RadixNode):
    cdef public list asns

cdef class RadixNodeData(RadixNode):
    cdef public dict data
