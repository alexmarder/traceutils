cdef class EmptyDict(dict):
    pass

cdef class ZeroDict(dict):
    pass

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

    cpdef RelType reltype(self, int x, int y);
