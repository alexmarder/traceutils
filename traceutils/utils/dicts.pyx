cdef class CustomDict(dict):
    def __getstate__(self):
        return dict(self)

    def __setstate__(self, state):
        self.update(state)

    def __reduce__(self):
        return self.__class__, (), self.__getstate__()


cdef class StrDict(CustomDict):
    def __missing__(self, int key):
        return str(key)


cdef class EmptyDict(CustomDict):
    def __missing__(self, key):
        return set()


cdef class ZeroDict(CustomDict):
    def __missing__(self, key):
        return 0
