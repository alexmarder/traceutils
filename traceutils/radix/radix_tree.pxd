from traceutils.radix.radix_node cimport RadixNode
from traceutils.radix.radix_prefix cimport RadixPrefix


cdef unsigned char addr_test(bytes addr, unsigned char bitlen);
cdef bint prefix_match(RadixPrefix left, RadixPrefix right, unsigned char bitlen);
# cdef bint prefix_match2(bytes left, bytes right, unsigned char bitlen);

cdef class RadixTree:
    # cdef unsigned char maxbits
    cdef RadixNode head
    cdef long active_nodes

    cdef RadixNode add(self, RadixPrefix prefix);
    cdef void remove(self, RadixNode node) except *;
    cdef RadixNode search_best(self, RadixPrefix prefix);
    cdef RadixNode search_exact(self, RadixPrefix prefix);
    cdef RadixNode search_worst(self, RadixPrefix prefix);
    cdef list search_covered(self, RadixPrefix prefix);
