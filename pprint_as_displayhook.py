import pprint
import sys

orig_displayhook = sys.displayhook


def myhook(value):
    if value is not None:
        if type(__builtins__) is dict:
            __builtins__['_'] = value
        else:
            __builtins__._ = value
        if hasattr(value, "__dict__"):
            value = vars(value)
        pprint.pprint(value)


def setup_myhook():
    if type(__builtins__) is dict:
        __builtins__['pprint_on'] = lambda: setattr(sys, 'displayhook', myhook)
        __builtins__['pprint_off'] = lambda: setattr(sys, 'displayhook', orig_displayhook)
    else:
        __builtins__.pprint_on = lambda: setattr(sys, 'displayhook', myhook)
        __builtins__.pprint_off = lambda: setattr(sys, 'displayhook', orig_displayhook)


setup_myhook()
pprint_on()
