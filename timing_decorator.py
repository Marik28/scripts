from functools import wraps
from time import time

# https://stackoverflow.com/a/27737385/17684642
def timing(f):
    """Measures function execution time"""
    @wraps(f)
    def wrap(*args, **kw):
        ts = time()
        result = f(*args, **kw)
        te = time()

        print('func:%r args:[%r, %r] took: %2.4f sec' % (f.__name__, args, kw, te - ts))
        return result

    return wrap
