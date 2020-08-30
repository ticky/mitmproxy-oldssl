# mitmproxy in Docker, with SSLv3 available

[Docker image of mitmproxy](https://github.com/mitmproxy/mitmproxy/tree/master/release/docker) with OpenSSL reconfigured to enable SSLv3; can be configured to act as an SSL downgrade proxy for old machines.

## Warnings up front

You probably don't want this unless you (think you) know what you're doing (and even then!). SSLv3 is ancient ([released in 1996](https://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0,_2.0,_and_3.0)!), vulnerable to [well-publicised attacks](https://en.wikipedia.org/wiki/POODLE), and the RC4 ciphers this enables are known to be weak as well.

You must not use this for anything important! Traffic sent with this protocol and these ciphers is *not* secured as of 2020, and anyone with access to the network in between can intercept, modify, or read your traffic sent over these protocols.

This must only be used within a secured network you trust strongly, and even then it is likely still a pretty bad idea.

Additionally, this cannot and will not protect you from real threats on the web. Vulnerabilities exist in the software this is designed to talk to, so if you happen to connect to a malicious server, your unprotected, obsolete computer *will* recieve whatever it's sending in full.

## If it's so bad then why did you do it?

I have a [PowerBook G4](https://en.wikipedia.org/wiki/PowerBook_G4#Titanium_PowerBook_G4), an admirable little computer from 2003, and I enjoy tinkering around with it and seeing what it can do. One of the things that's hardest on it is support for the modern web. JavaScript support is lacking, as are the rendering engines by comparison to today's browsers, but the biggest problem is TLS support; Mac OS 9 software supports TLSv1.0 in the absolute best case (and this example, Classilla, is much, much more recent than anything else), and generally only SSLv3 (Internet Explorer:mac 5.1).

My plan is to run this, exposed only to my internal network, as an opt-in proxy for older machines, with a configuration set to allow older protocols on the client side, but to request newer protocols and ciphers on the server side, effectively upgrading the SSL support of the older machines. I'm also pondering a hardware solution which would enable the entire low-security attack vector to reside within a single, short ethernet cable.

One important thing not included (yet?) in this repository is a mitmproxy plugin I've written which lets it validate server certificates even if the client itself doesn't support [Server Name Indication](https://en.wikipedia.org/wiki/Server_Name_Indication). SNI has become a vital component of the modern web, being the magic which makes TLS work on virtual hosts, and older browsers simply do not implement it. Thus, this mitmproxy image will not, out of the box, do everything you need to get old browsers browsing the current web. I am at this point still mulling over the merits of sharing that.
