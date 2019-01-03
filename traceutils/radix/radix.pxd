from traceutils.radix.radix_node cimport RadixNode
from traceutils.radix.radix_tree cimport RadixTree
from traceutils.radix.radix_prefix cimport RadixPrefix

cdef list _search_covering(RadixNode node);

cdef class Radix:
    cdef RadixTree _tree4
    cdef RadixTree _tree6
    cdef long gen_id

    cdef RadixNode _add(self, RadixPrefix prefix, long asn=*);
    cdef void _delete(self, RadixNode node) except *;
    cdef RadixNode _search_exact(self, RadixPrefix prefix);
    cdef RadixNode _search_best(self, RadixPrefix prefix);
    cdef RadixNode _search_worst(self, RadixPrefix prefix);
    cdef list _search_covered(self, RadixPrefix prefix);

    cpdef RadixNode add(self, str network, short masklen=*, long asn=*);
    cpdef RadixNode add_packed(self, bytes packed, unsigned char masklen, long asn=*);
    cpdef void delete(self, str network, short masklen=*) except *;
    cpdef void delete_packed(self, bytes packed, unsigned char masklen) except *;
    cpdef RadixNode search_exact(self, str addr);
    cpdef RadixNode search_exact_prefix(self, str network, short masklen=*);
    cpdef RadixNode search_exact_packed(self, bytes packed, unsigned char masklen);
    cpdef RadixNode search_best(self, str addr);
    cpdef RadixNode search_best_prefix(self, str network, short masklen=*);
    cpdef RadixNode search_best_packed(self, bytes packed, unsigned char masklen);
    cpdef RadixNode search_worst(self, str addr);
    cpdef RadixNode search_worst_prefix(self, str network, short masklen=*);
    cpdef RadixNode search_worst_packed(self, bytes packed, unsigned char masklen);
    cpdef list search_covered(self, str addr);
    cpdef list search_covered_prefix(self, str network, short masklen=*);
    cpdef list search_covered_packed(self, bytes packed, unsigned char masklen);
    cpdef list search_covering(self, str addr);
    cpdef list search_covering_prefix(self, str network, short masklen=*);
    cpdef list search_covering_packed(self, bytes packed, unsigned char masklen);
    cpdef list nodes(self);
    cpdef list prefixes(self)
