cdef infer_compression(str filename, str mode=*);

cdef class File2:
    cdef str filename
    cdef str mode
    cdef f

    cpdef read(self, int size=*);
    cpdef readline(self);
    cpdef open(self);
    cpdef void close(self) except *;
    cpdef void write(self, data) except *;
    cpdef void writelines(self, lines) except *;

# cpdef fopen(str filename, str mode=*, *args, **kwargs);
