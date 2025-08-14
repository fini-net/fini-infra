#!/usr/bin/env -S uv run --script

from diagrams import Diagram
from diagrams.azure.general import Usericon
from diagrams.custom import Custom

with Diagram("Otel example", show=False):
    user = Usericon("web user")
    otel = Custom("Otel","./icons/otel.png")

    user >> otel


print("Done generating diagrams, no preview is coming.")
