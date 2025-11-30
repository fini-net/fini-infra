#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "diagrams",
# ]
# ///

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.general import Usericon
from diagrams.digitalocean.compute import Droplet
from diagrams.digitalocean.network import Firewall, LoadBalancer
from diagrams.saas.cdn import Cloudflare
from diagrams.onprem.vcs import Github
from diagrams.programming.framework import React

_graph_attr = {
    "fontsize": "45",
    "fontname": "Inter, Arial",
    "labelloc": "t",
}

_node_attr = {
    "fontname": "Inter, Arial",
    "fontsize": "20",
}

_edge_attr = {
    "fontname": "Inter, Arial",
    "fontsize": "18",
}

with Diagram(
    "DigitalOcean App Platform Static Site",
    graph_attr=_graph_attr,
    node_attr=_node_attr,
    edge_attr=_edge_attr,
    show=False,
):
    user = Usericon("web user")
    github = Github("GitHub Repo\n(Static Site Source)")

    with Cluster("Cloudflare CDN\n(White-label Provider)", graph_attr={"style": "dashed", "color": "orange"}):
        cdn = Cloudflare("Global CDN\nEdge Network")

    with Cluster("DigitalOcean App Platform"):
        lb = LoadBalancer("App Platform\nLoad Balancer")

        with Cluster("Static Site Instances"):
            app1 = Droplet("Instance 1")
            app2 = Droplet("Instance 2")
            app3 = Droplet("Instance 3")

        firewall = Firewall("Cloud Firewall")

    # Unknown log destination - using Droplet with question mark styling
    unknown = Droplet("Unknown\nLog Destination\n❓")

    # Deployment flow
    github >> Edge(label="deploy", color="blue", style="bold") >> [app1, app2, app3]

    # User traffic flow through Cloudflare CDN
    user >> Edge(label="https") >> cdn
    cdn >> Edge(label="cache/proxy", color="orange") >> lb
    lb >> Edge(label="route") >> [app1, app2, app3]

    # Security
    firewall >> Edge(label="protects", style="dashed") >> lb

    # Logs to unknown destination
    app1 >> Edge(label="logs", style="dotted", color="grey") >> unknown
    app2 >> Edge(label="logs", style="dotted", color="grey") >> unknown
    app3 >> Edge(label="logs", style="dotted", color="grey") >> unknown

print("Done generating DigitalOcean App Platform static site diagram.")
