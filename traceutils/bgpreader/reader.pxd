cdef bint valid(long asn);
cdef list handle_sets(bytes asset);
cdef char *next_split(char *delimeters, int n);
cpdef read(str filename);
