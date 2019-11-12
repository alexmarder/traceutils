from traceutils.radix.radix_prefix cimport RadixPrefix

cdef class RadixNode:
    cdef public RadixPrefix prefix
    cdef RadixNode parent, left, right
    cdef public unsigned char bitlen
    cdef public long asn
    # cdef public dict data