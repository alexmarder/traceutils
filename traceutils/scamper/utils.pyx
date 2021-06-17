from traceutils.scamper.warts cimport WartsReader, WartsJsonReader

from traceutils.scamper.atlas cimport AtlasReader

cpdef Reader reader(str filename, TraceFType ftype=TraceFType.none):
    if ftype == TraceFType.none:
        if filename.endswith('warts') or filename.endswith('warts.gz') or filename.endswith('warts.bz2'):
            return WartsReader(filename)
        else:
            return WartsJsonReader(filename)
    if ftype == TraceFType.warts:
        return WartsReader(filename)
    elif ftype == TraceFType.wartsjson:
        return WartsJsonReader(filename)
    elif ftype == TraceFType.atlas:
        return AtlasReader(filename)
    else:
        raise Exception('Unknown file type: {}'.format(ftype))