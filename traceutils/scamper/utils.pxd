from traceutils.scamper.hop cimport Reader, TraceFType

cpdef Reader reader(str filename, TraceFType ftype=*, bint safe=*);