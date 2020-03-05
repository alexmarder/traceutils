cimport cython

from traceutils.radix.radix_node cimport RadixNode, RadixNodeASNs
from traceutils.radix.radix_prefix cimport RadixPrefix


# @cython.boundscheck(False)
# @cython.overflowcheck(False)
cdef unsigned char addr_test(bytes addr, unsigned char bitlen):
    cdef unsigned char left, right, bitand, bitshift
    bitshift = bitlen >> 3
    bitand = bitlen & 0x07
    left = addr[bitshift]
    right = 0x80 >> bitand
    return left & right


@cython.cdivision(True)
# @cython.boundscheck(False)
# @cython.overflowcheck(False)
cdef bint prefix_match(RadixPrefix left, RadixPrefix right, unsigned char bitlen) except -1:
    cdef bytes laddr, raddr
    cdef unsigned char quotient, remainder, mask, bitmainder, lmask, rmask, biteq
    laddr = left.addr
    raddr = right.addr
    if laddr is None or raddr is None:
        return False
    try:
        quotient = bitlen / 8
        for i in range(quotient):
            if laddr[i] != raddr[i]:
                return False
    except TypeError:
        # print(laddr, raddr, type(laddr) == type(bytes), type(raddr) == type(bytes))
        return False
        # raise
    remainder = bitlen % 8
    if remainder == 0:
        return True
    bitmainder = 8 - remainder
    mask = (~0) << bitmainder
    # mask = (~0) << (8 - remainder)
    lmask = laddr[quotient] & mask
    rmask = raddr[quotient] & mask
    biteq = lmask == rmask
    return biteq


cdef class RadixTree:

    def __init__(self):
        # self.maxbits = 128
        self.head = None
        self.active_nodes = 0

    cdef RadixNode create_node(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None):
        return RadixNode(prefix, prefix_size, parent)

    cdef RadixNode add(self, RadixPrefix prefix):
        cdef RadixNode head, parent, new_node, glue_node
        cdef bytes addr, test_addr
        cdef unsigned char bitlen, check_bit, differ_bit, i, r, j

        node = self.head
        if node is None:
            # easy case
            node = self.create_node(prefix)
            self.head = node
            self.active_nodes += 1
            return node
        addr = prefix.addr
        bitlen = prefix.bitlen
        # find the best place for the node
        while node.bitlen < bitlen or node.prefix is None:
            if addr_test(addr, node.bitlen):
                if node.right is None:
                    break
                node = node.right
            else:
                if node.left is None:
                    break
                node = node.left
        # find the first differing bit
        test_addr = node.prefix.addr
        check_bit = node.bitlen if node.bitlen < bitlen else bitlen
        differ_bit = 0
        i = 0
        while i * 8 < check_bit:
            r = addr[i] ^ test_addr[i]
            if r == 0:
                differ_bit = (i + 1) * 8
                i += 1
                continue
            # bitwise check
            for j in range(8):
                if r & (0x80 >> j):
                    break
            differ_bit = i * 8 + j
            break
        if differ_bit > check_bit:
            differ_bit = check_bit
        # now figure where to insert
        parent = node.parent
        while parent and parent.bitlen >= differ_bit:
            node, parent = parent, node.parent
        # found a match
        if differ_bit == bitlen and node.bitlen == bitlen:
            if not node.prefix:
                node.prefix = prefix
            return node
        # no match, new node
        new_node = self.create_node(prefix)
        self.active_nodes += 1
        # fix it up
        if node.bitlen == differ_bit:
            new_node.parent = node
            if addr_test(addr, node.bitlen):
                node.right = new_node
            else:
                node.left = new_node
            return new_node
        if bitlen == differ_bit:
            if addr_test(test_addr, bitlen):
                new_node.right = node
            else:
                new_node.left = node
            new_node.parent = node.parent
            if node.parent is None:
                self.head = new_node
            elif node.parent.right == node:
                node.parent.right = new_node
            else:
                node.parent.left = new_node
            node.parent = new_node
        else:
            glue_node = self.create_node(prefix=None, prefix_size=differ_bit, parent=node.parent)
            self.active_nodes += 1
            if addr_test(addr, differ_bit):
                glue_node.right = new_node
                glue_node.left = node
            else:
                glue_node.right = node
                glue_node.left = new_node
            new_node.parent = glue_node
            if node.parent is None:
                self.head = glue_node
            elif node.parent.right == node:
                node.parent.right = glue_node
            else:
                node.parent.left = glue_node
            node.parent = glue_node
        return new_node

    cdef void remove(self, RadixNode node) except *:
        cdef RadixNode parent, child

        if node.right and node.left:
            node.prefix.addr = None
            node.asn = 0
            node.bitlen = 0
            return
        if node.right is None and node.left is None:
            parent = node.parent
            self.active_nodes -= 1
            if parent is None:
                self.head = None
                return
            if parent.right == node:
                parent.right = None
                child = parent.left
            else:
                parent.left = None
                child = parent.right
            if parent.prefix:
                return
            # remove the parent too
            if parent.parent is None:
                self.head = child
            elif parent.parent.right == parent:
                parent.parent.right = child
            else:
                parent.parent.left = child
            child.parent = parent.parent
            self.active_nodes -= 1
            return
        if node.right:
            child = node.right
        else:
            child = node.left
        parent = node.parent
        child.parent = parent
        self.active_nodes -= 1

        if parent is None:
            self.head = child
            return
        if parent.right == node:
            parent.right = child
        else:
            parent.left = child
        return

    cdef RadixNode search_best(self, RadixPrefix prefix):
        cdef RadixNode node
        cdef bytes addr
        cdef unsigned char bitlen
        cdef list stack

        if self.head is None:
            return None
        node = self.head
        addr = prefix.addr
        bitlen = prefix.bitlen

        stack = []
        while node.bitlen < bitlen:
            if node.prefix:
                stack.append(node)
            if addr_test(addr, node.bitlen):
                node = node.right
            else:
                node = node.left
            if node is None:
                break
        if node and node.prefix:
            stack.append(node)
        # for node in reversed(stack):
        for i in range(len(stack) - 1, -1, -1):
            node = stack[i]
            if node.bitlen <= bitlen and prefix_match(node.prefix, prefix, node.bitlen):
                return node
        return None

    cdef RadixNode search_exact(self, RadixPrefix prefix):
        cdef RadixNode node
        cdef bytes addr
        cdef unsigned char bitlen

        if self.head is None:
            return None
        node = self.head
        addr = prefix.addr
        bitlen = prefix.bitlen

        while node.bitlen < bitlen:
            if addr_test(addr, node.bitlen):
                node = node.right
            else:
                node = node.left
            if node is None:
                return None

        if node.bitlen > bitlen or node.prefix is None:
            return None

        if prefix_match(node.prefix, prefix, bitlen):
            return node
        return None

    cdef RadixNode search_worst(self, RadixPrefix prefix):
        cdef RadixNode node
        cdef bytes addr
        cdef unsigned char bitlen

        if self.head is None:
            return None
        node = self.head
        addr = prefix.addr
        bitlen = prefix.bitlen

        stack = []
        while node.bitlen < bitlen:
            if node.prefix:
                stack.append(node)
            if addr_test(addr, node.bitlen):
                node = node.right
            else:
                node = node.left
            if node is None:
                break
        if node and node.prefix:
            stack.append(node)
        if len(stack) <= 0:
            return None
        for node in stack:
            if prefix_match(node.prefix, prefix, node.bitlen):
                return node
        return None

    cdef list search_covered(self, RadixPrefix prefix):
        cdef list results, stack
        cdef RadixNode node
        cdef bytes addr
        cdef unsigned char bitlen

        results = []
        if self.head is None:
            return results
        node = self.head
        addr = prefix.addr
        bitlen = prefix.bitlen

        while node.bitlen < bitlen:
            if addr_test(addr, node.bitlen):
                node = node.right
            else:
                node = node.left
            if node is None:
                return results

        stack = [node]
        while stack:
            node = stack.pop()
            if prefix_match(node.prefix, prefix, prefix.bitlen):
                results.append(node)
            if node.right:
                stack.append(node.right)
            if node.left:
                stack.append(node.left)

        return results

cdef class RadixTreeASN(RadixTree):

    cdef RadixNode create_node(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None):
        return RadixNodeASN(prefix, prefix_size, parent)

    cdef RadixNodeASN add_asn(self, RadixPrefix prefix, int asn):
        cdef RadixNodeASN node = <RadixNodeASN> self.add(prefix)
        node.asn = asn
        return node

cdef class RadixTreeASNs(RadixTree):

    cdef RadixNode create_node(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None):
        return RadixNodeASNs(prefix, prefix_size, parent)

    cdef RadixNodeASNs add_asns(self, RadixPrefix prefix, list asns):
        cdef RadixNodeASNs node = <RadixNodeASNs> self.add(prefix)
        node.asns = asns
        return node

cdef class RadixTreeData(RadixTree):

    cdef RadixNode create_node(self, RadixPrefix prefix=None, unsigned char prefix_size=0, RadixNode parent=None):
        return RadixNodeData(prefix, prefix_size, parent)

    cdef RadixNodeData add_data(self, RadixPrefix prefix, dict data=None):
        cdef RadixNodeData node = <RadixNodeData> self.add(prefix)
        if data is not None:
            node.data.update(data)
        return node
