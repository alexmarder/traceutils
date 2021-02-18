from traceutils.ixps.peeringdb_base import AbstractPeeringDB
from traceutils.ixps import peeringdb, peeringdb_v1
from traceutils.ixps.peeringdb import PeeringDB
from traceutils.ixps.caida import CaidaIXPs


def create_peeringdb(filename):
    if filename.endswith('.json'):
        return peeringdb.PeeringDB(filename)
    try:
        return peeringdb.PeeringDB(filename)
    except:
        return peeringdb_v1.PeeringDB(filename)
