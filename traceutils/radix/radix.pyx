from socket import AF_INET

from traceutils.radix.radix_tree cimport RadixTree, RadixTreeASN
from traceutils.radix.radix_node cimport RadixNode
from traceutils.radix.radix_prefix cimport from_packed, from_network, from_address, RadixPrefix


def _iter(RadixNode node):
    cdef list stack
    stack = []
    while node is not None:
        if node.prefix:
            yield node
        if node.left:
            if node.right:
                # we'll come back to it
                stack.append(node.right)
            node = node.left
        elif node.right:
            node = node.right
        elif len(stack) != 0:
            node = stack.pop()
        else:
            break


cdef list _search_covering(RadixNode node):
    cdef list stack
    stack = []
    while node is not None:
        if node.prefix:
            stack.append(node)
        node = node.parent
    return stack


cdef class Radix:

    def __init__(self, RadixTree tree4=None, RadixTree tree6=None):
        self._tree4 = tree4 if tree4 is not None else RadixTree()
        self._tree6 = tree6 if tree6 is not None else RadixTree()
        self.gen_id = 0            # detection of modifiction during iteration

    def __iter__(self):
        cdef long init_id
        cdef RadixNode elt
        init_id = self.gen_id
        for elt in _iter(self._tree4.head):
            if init_id != self.gen_id:
                raise RuntimeWarning('detected modification during iteration')
            yield elt
        for elt in _iter(self._tree6.head):
            if init_id != self.gen_id:
                raise RuntimeWarning('detected modification during iteration')
            yield elt

    cdef RadixNode _add(self, RadixPrefix prefix):
        cdef RadixNode node
        if prefix.family == AF_INET:
            node = self._tree4.add(prefix)
        else:
            node = self._tree6.add(prefix)
        self.gen_id += 1
        return node

    cdef void _delete(self, RadixNode node) except *:
        if not node:
            raise KeyError('match not found')
        if node.prefix.family == AF_INET:
            self._tree4.remove(node)
        else:
            self._tree6.remove(node)
        self.gen_id += 1

    cdef RadixNode _search_exact(self, RadixPrefix prefix):
        if prefix.family == AF_INET:
            return self._tree4.search_exact(prefix)
        else:
            return self._tree6.search_exact(prefix)

    cdef RadixNode _search_best(self, RadixPrefix prefix):
        if prefix.family == AF_INET:
            return self._tree4.search_best(prefix)
        else:
            return self._tree6.search_best(prefix)

    cdef RadixNode _search_worst(self, RadixPrefix prefix):
        if prefix.family == AF_INET:
            return self._tree4.search_worst(prefix)
        else:
            return self._tree6.search_worst(prefix)

    cdef list _search_covered(self, RadixPrefix prefix):
        if prefix.family == AF_INET:
            return self._tree4.search_covered(prefix)
        return self._tree6.search_covered(prefix)

    cpdef RadixNode add(self, str network, short masklen=-1):
        return self._add(from_network(network, masklen))

    cpdef RadixNode add_packed(self, bytes packed, unsigned char masklen):
        return self._add(from_packed(packed, masklen))

    cpdef void delete(self, str network, short masklen=-1) except *:
        self._delete(self.search_exact_prefix(network, masklen))

    cpdef void delete_packed(self, bytes packed, unsigned char masklen) except *:
        self._delete(self.search_exact_packed(packed, masklen))

    cpdef RadixNode search_exact(self, str addr):
        return self._search_exact(from_address(addr))

    cpdef RadixNode search_exact_prefix(self, str network, short masklen=-1):
        return self._search_exact(from_network(network, masklen))

    cpdef RadixNode search_exact_packed(self, bytes packed, unsigned char masklen):
        return self._search_exact(from_packed(packed, masklen))

    cpdef RadixNode search_best(self, str addr):
        return self._search_best(from_address(addr))

    cpdef RadixNode search_best_prefix(self, str network, short masklen=-1):
        return self._search_best(from_network(network, masklen))

    cpdef RadixNode search_best_packed(self, bytes packed, unsigned char masklen):
        return self._search_best(from_packed(packed, masklen))

    cpdef RadixNode search_worst(self, str addr):
        return self._search_worst(from_address(addr))

    cpdef RadixNode search_worst_prefix(self, str network, short masklen=-1):
        return self._search_worst(from_network(network, masklen))

    cpdef RadixNode search_worst_packed(self, bytes packed, unsigned char masklen):
        return self._search_worst(from_packed(packed, masklen))

    cpdef list search_covered(self, str addr):
        return self._search_covered(from_address(addr))

    cpdef list search_covered_prefix(self, str network, short masklen=-1):
        return self._search_covered(from_network(network, masklen))

    cpdef list search_covered_packed(self, bytes packed, unsigned char masklen):
        return self._search_covered(from_packed(packed, masklen))

    cpdef list search_covering(self, str addr):
        return _search_covering(self.search_best(addr))

    cpdef list search_covering_prefix(self, str network, short masklen=-1):
        return _search_covering(self.search_best_prefix(network, masklen))

    cpdef list search_covering_packed(self, bytes packed, unsigned char masklen):
        return _search_covering(self.search_best_packed(packed, masklen))

    cpdef list nodes(self):
        cdef RadixNode elt
        return [elt for elt in self]

    cpdef list prefixes(self):
        cdef RadixNode elt
        return [str(elt.prefix) for elt in self]
