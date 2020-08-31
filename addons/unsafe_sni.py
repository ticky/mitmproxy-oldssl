import ipaddress
from mitmproxy import exceptions
from mitmproxy.net import tls
from mitmproxy.proxy.protocol import TlsLayer, HttpLayer

"""Treat old browsers' CONNECT host names as valid for remote server SNI checks
Note that this is dangerous and may allow redirection of connections to an
untrusted server by anyone sharing a network with the client machine.
Do not expose this to the internet, and do not use this on unsecured networks.
"""
class UnsafeSNI:
    def _is_domain_name(self, host):
        try:
            ipaddress.ip_address(host)
            return False
        except ValueError:
            return True

    def next_layer(self, next_layer):
        prev_layer = next_layer.ctx
        print(f'UnsafeSNI: next_layer: {next_layer}, prev_layer: {prev_layer}')

        # When transitioning from an HTTP next_layer to a TLS next_layer,
        # we have an established server connection, and the client is
        # not using Server Name Indication
        if (isinstance(next_layer, TlsLayer) and isinstance(prev_layer, HttpLayer)
            and next_layer._client_tls and prev_layer.server_conn is not None
            and next_layer.client_conn.sni is None):

            print(f'UnsafeSNI: prev_layer.server_conn.address: {prev_layer.server_conn.address}, next_layer.client_conn.sni: {next_layer.client_conn.sni}')

            connection_hostname = prev_layer.server_conn.address[0]

            if self._is_domain_name(connection_hostname):
                print(f'UnsafeSNI: {connection_hostname} looks like a domain name!')

                try:
                    client_hello = tls.ClientHello.from_file(next_layer.client_conn.rfile)
                except exceptions.TlsProtocolException as e:
                    print("UnsafeSNI: Cannot parse Client Hello: %s" % repr(e), "error")

                print(f'UnsafeSNI: client_hello: {client_hello}, cipher_suites: {client_hello.cipher_suites}, extensions: {client_hello.extensions}, _client_hello.version: {client_hello._client_hello.version.major}.{client_hello._client_hello.version.minor}')

                if client_hello is not None and client_hello.sni is None:
                    print(f'UnsafeSNI: client has not presented SNI; overriding with {connection_hostname}')
                    next_layer._custom_server_sni = connection_hostname

            else:
                print(f'UnsafeSNI: {connection_hostname} doesn\'t seem to be a domain name; ignoring')

            print(f'UnsafeSNI: next_layer._client_tls: {next_layer._client_tls}, next_layer._client_hello: {next_layer._client_hello}, next_layer._custom_server_sni: {next_layer._custom_server_sni}')

addons = [UnsafeSNI()]
