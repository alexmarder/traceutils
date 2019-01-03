cdef class CustomDict(dict):
    pass

cdef class StrDict(CustomDict):
    pass

cdef class EmptyDict(CustomDict):
    pass

cdef class ZeroDict(CustomDict):
    pass
