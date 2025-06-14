#!/Users/chicks/.pyenv/versions/3.13.5/bin/python

from diagrams import Diagram
from diagrams.azure.general import Usericon
from diagrams.digitalocean.network import Firewall
from diagrams.digitalocean.storage import Space

with Diagram("FINI Static Web Serving"):
        Usericon("web user") >> Firewall("CDN") >> Space("bucket")
