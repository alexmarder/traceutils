from traceutils.utils.dicts cimport EmptyDict, ZeroDict

cpdef enum RelType:
    provider = 1
    customer = 2
    peer = 3
    none = 4

cdef class BGP:
    cdef readonly set rels
    cdef readonly EmptyDict customers
    cdef readonly EmptyDict providers
    cdef readonly EmptyDict peers
    cdef readonly EmptyDict cone
    cdef readonly ZeroDict conesize

    cpdef bint customer_rel(self, int x, int y) except *;
    cpdef set multi_customers(self, asns);
    cpdef set multi_peers(self, asns);
    cpdef set multi_providers(self, asns);
    cpdef bint multi_rels(self, asn, others) except *;
    cpdef bint peer_rel(self, int x, int y) except *;
    cpdef bint provider_rel(self, int x, int y) except *;
    cpdef bint rel(self, int x, int y) except *;
    cpdef RelType reltype(self, int x, int y);
