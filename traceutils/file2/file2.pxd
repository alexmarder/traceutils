cdef infer_compression(str filename, str mode=*);

cdef class File2:
    cdef str filename
    cdef str mode
    cdef f

    cpdef open(self);
    cpdef void close(self) except *;