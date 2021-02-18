from itertools import filterfalse, groupby
from operator import itemgetter
from libc.math cimport NAN, isnan, INFINITY


cpdef list max_num(iterable, key=None):
    cdef:
        list max_items = []
        float max_value = float('-inf')
        float value
    for item, value in zip(iterable, (map(key, iterable) if key else iterable)):
        if value > max_value:
            max_items = [item]
            max_value = value
        elif value == max_value:
            max_items.append(item)
    return max_items


cpdef tuple max2(iterable, key=None):
    cdef:
        float first_value = -INFINITY
        float second_value = -INFINITY
        float n
    first = None
    second = None
    for v in iterable:
        n = key(v) if key is not None else v
        if n > first_value:
            second = first
            second_value = first_value
            first = v
            first_value = n
        elif n > second_value:
            second = v
            second_value = n
    return first, first_value, second, second_value

cpdef tuple max2_values(iterable):
    cdef:
        float first_value = -INFINITY
        float second_value = -INFINITY
        float n
    first = None
    second = None
    for v, n in iterable.items():
        if n > first_value:
            second = first
            second_value = first_value
            first = v
            first_value = n
        elif n > second_value:
            second = v
            second_value = n
    return first, first_value, second, second_value

def unique_everseen(iterable, key=None):
    cdef set seen = set()
    seen_add = seen.add
    if key is None:
        for element in filterfalse(seen.__contains__, iterable):
            seen_add(element)
            yield element
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                seen_add(k)
                yield element


def unique_single_element(iterable, key=None):
    seen = set()
    if key is None:
        for element in filterfalse(seen.__contains__, iterable):
            if len(seen) > 0:
                return False
            seen.add(element)
    else:
        for element in iterable:
            k = key(element)
            if k not in seen:
                if len(seen) > 0:
                    return False
                seen.add(k)
    return True


def read_filenames(filename):
    with open(filename) as f:
        for line in f:
            if not line.startswith('#'):
                line = line.strip()
                if line:
                    yield line


cpdef peek(s):
    for i in s:
        return i


def unique_justseen(iterable, key=None):
    """List unique elements, preserving order. Remember only the element just seen."""
    # unique_justseen('AAAABBBCCDAABBB') --> A B C D A B
    # unique_justseen('ABBCcAD', str.lower) --> A B C A D
    return map(next, map(itemgetter(1), groupby(iterable, key)))