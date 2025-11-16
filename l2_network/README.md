# `l2_network`

Lee Briggs said:

> The network layer is foundational to how everything will work in your
> infrastructure.
>
> ## Example Resources
>
> - AWS: VPCs, Subnets, Route Tables, Internet Gateways, NAT Gateways, VPNs
> - Azure: Virtual Networks, Subnets, Route Tables, VPN Gateways
> - Google Cloud: VPC Networks, Subnets, Cloud Router, Cloud VPN

## Don't forget DNS

Somehow Lee Briggs forgot about DNS!  But it belongs at the network layer
in our opinion.

Yet you're not going to see any of our DNS here, because we're currently
managing that in a private repo.  We hope to open that up someday, but in the
meantime we can show you how we do it by looking at the
[fini-coredns-example][fini-coredns-example] repository.  There we demonstrate
how powerful and painless [DNSControl][dnscontrol] can be.  That is the same
tooling we are using internally and we will be updating the
[fini-coredns-example][fini-coredns-example] with new discoveries from the
private repo.

## DigitalOcean Resources

- [VPCs][do-vpc] - Virtual Private Clouds
- [Firewalls][do-firewall] - Cloud firewalls
- [Reserved IPs][do-reserved-ip] - Static IP addresses

[do-vpc]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/vpc
[do-firewall]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/firewall
[do-reserved-ip]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/reserved_ip
[fini-coredns-example]: https://github.com/fini-net/fini-coredns-example
[dnscontrol]: https://github.com/StackExchange/dnscontrol
