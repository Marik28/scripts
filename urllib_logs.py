def enable_urllib_logger():
    import http.client as http_client
    import logging
    http_client.HTTPConnection.debuglevel = 1
    logging.basicConfig()
    logging.getLogger().setLevel(logging.DEBUG)
    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.DEBUG)
    requests_log.propagate = True


def disable_urllib_logger():
    import logging
    requests_log = logging.getLogger("requests.packages.urllib3")
    requests_log.setLevel(logging.NOTSET)
    requests_log.propagate = False

enable_urllib_logger()
