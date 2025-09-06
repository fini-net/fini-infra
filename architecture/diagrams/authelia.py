#!/usr/bin/env -S uv run --script

from diagrams import Cluster, Diagram, Edge
from diagrams.azure.general import Usericon
from diagrams.digitalocean.compute import Droplet
from diagrams.digitalocean.database import DbaasPrimary
from diagrams.digitalocean.network import Firewall, LoadBalancer
from diagrams.onprem.auth import Oauth2Proxy
from diagrams.onprem.database import Mysql
from diagrams.onprem.inmemory import Redis
from diagrams.onprem.network import Nginx

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
    "Authelia SSO Infrastructure",
    graph_attr=_graph_attr,
    node_attr=_node_attr,
    edge_attr=_edge_attr,
    show=False,
):
    user = Usericon("Users")
    
    with Cluster("DigitalOcean VPC"):
        lb = LoadBalancer("Load Balancer")
        
        with Cluster("Web Layer"):
            proxy = Nginx("Reverse Proxy")
            authelia = Oauth2Proxy("Authelia SSO")
        
        with Cluster("Application Layer"):
            app1 = Droplet("App Server 1")
            app2 = Droplet("App Server 2")
            app3 = Droplet("Protected App")
        
        with Cluster("Data Layer"):
            mysql = Mysql("MySQL\n(User Store)")
            redis = Redis("Redis\n(Sessions)")
        
        firewall = Firewall("Cloud Firewall")

    # User authentication flow
    user >> Edge(label="https://app.example.com") >> lb
    lb >> Edge(label="route traffic") >> proxy
    proxy >> Edge(label="auth check") >> authelia
    
    # Successful authentication
    authelia >> Edge(label="authenticated", color="green") >> proxy
    proxy >> Edge(label="forward request", color="green") >> [app1, app2, app3]
    
    # Authelia data connections
    authelia >> Edge(label="user lookup") >> mysql
    authelia >> Edge(label="session store") >> redis
    
    # Security
    firewall >> Edge(label="protects", style="dashed") >> [proxy, authelia]
    firewall >> Edge(label="protects", style="dashed") >> [app1, app2, app3]

print("Done generating Authelia SSO diagram.")