#!/usr/bin/env -S uv run --script

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.general import Usericon
from diagrams.digitalocean.network import Firewall
from diagrams.digitalocean.storage import Space
from diagrams.onprem.monitoring import Prometheus

with Diagram("FINI Static Web Serving", show=False):
    user = Usericon("web user")
    cdn = Firewall("CDN")
    storage = Space("bucket")
    monitoring = Prometheus("Prometheus/Grafana")

    # user traffic
    user >> Edge(label="web public") >> cdn >> Edge(label="web internal") >> storage

    # monitoring
    cdn >> Edge(label="metrics", style="dashed") >> monitoring
    storage >> Edge(label="metrics", style="dashed") >> monitoring



print("Done generating diagrams, no preview is coming.")
