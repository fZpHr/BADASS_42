# BADASS

Network simulation project (42). Builds a multi-site routed network in GNS3
using Docker images, then deploys a BGP EVPN overlay for Layer 2/3
interconnection across sites.

## Topology

The lab is built in three parts (`p1`, `p2`, `p3`), progressively adding
routing, the EVPN control plane, and overlay services. Routing is handled by
FRRouting (`p1/frrouting`).

## Concepts

- BGP (RFC 4271) and MP-BGP (RFC 4760)
- BGP EVPN as the control plane for a VXLAN overlay
- FRRouting configuration
- Containerized network nodes under GNS3

## Stack

GNS3, Docker, FRRouting, Linux networking.
