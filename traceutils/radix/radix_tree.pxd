from traceutils.radix.radix_node cimport RadixNode, RadixNodeASN, RadixNodeASNs, RadixNodeData
from traceutils.radix.radix_prefix cimport RadixPrefix


cdef unsigned char addr_test(bytes addr, unsigned char bitlen);
cdef bint prefix_match(RadixPrefix left, RadixPrefix right, unsigned char bitlen) except -1;
# cdef bint prefix_match2(bytes left, bytes right, unsigned char bitlen);

cdef class RadixTree:
    # cdef unsigned char maxbits
    cdef RadixNode head
    cdef long active_nodes

    cdef RadixNode create_node(self, RadixPrefix prefix=*, unsigned char prefix_size=*, RadixNode parent=*);
    cdef RadixNode add(self, RadixPrefix prefix);
    cdef void remove(self, RadixNode node) except *;
    cdef RadixNode search_best(self, RadixPrefix prefix);
    cdef RadixNode search_exact(self, RadixPrefix prefix);
    cdef RadixNode search_worst(self, RadixPrefix prefix);
    cdef list search_covered(self, RadixPrefix prefix);

cdef class RadixTreeASN(RadixTree):
    cdef RadixNodeASN add_asn(self, RadixPrefix prefix, int asn);

cdef class RadixTreeASNs(RadixTree):
    cdef RadixNodeASNs add_asns(self, RadixPrefix prefix, list asns);

cdef class RadixTreeData(RadixTree):
    cdef RadixNodeData add_data(self, RadixPrefix prefix, dict data=*)
