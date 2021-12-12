from traceutils.scamper.warts cimport WartsReader, WartsJsonReader

from traceutils.scamper.atlas cimport AtlasReader

cpdef Reader reader(str filename, TraceFType ftype=TraceFType.none, bint safe=True):
    if ftype == TraceFType.none:
        if filename.endswith('warts') or filename.endswith('warts.gz') or filename.endswith('warts.bz2'):
            return WartsReader(filename, safe=safe)
        else:
            return WartsJsonReader(filename, safe=safe)
    if ftype == TraceFType.warts:
        return WartsReader(filename, safe=safe)
    elif ftype == TraceFType.wartsjson:
        return WartsJsonReader(filename, safe=safe)
    elif ftype == TraceFType.atlas:
        return AtlasReader(filename)
    else:
        raise Exception('Unknown file type: {}'.format(ftype))