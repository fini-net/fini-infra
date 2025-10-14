# `l4_data`

Lee Briggs said:

> The data layer is where the resources you’re managing really start to open
> up. This is where you’ll find things like databases, object stores, message
> queues, and anything else that’s used to store or transfer data.
>
> ## Example Resources
>
> - AWS: RDS, DynamoDB, S3, SQS, SNS, Kinesis, Redshift, DocumentDB,
>   ElastiCache, DynamoDB
> - Azure: SQL, CosmosDB, Blob Storage, Queue Storage, Event Grid, Event Hubs,
>   Service Bus, Redis Cache
> - Google Cloud: Cloud SQL, Cloud Spanner, Cloud Storage, Cloud Pub/Sub, Cloud
>   Datastore, Cloud Bigtable, Cloud Memorystore

## DigitalOcean Resources

- [Managed Databases][do-database] - PostgreSQL, MySQL, Redis, MongoDB
- [Spaces][do-spaces] - S3-compatible object storage
- [Spaces Bucket Objects][do-spaces-object] - Object storage management

[do-database]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/database_cluster
[do-spaces]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket
[do-spaces-object]: https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_object

## DO Spaces notes

- `nyc3` is the only `nyc` data center with Spaces, Container Registry, or Functions
  at the time of the writing.  Check the
  [official docs](https://docs.digitalocean.com/platform/regional-availability/#other-digitalocean-products)
  for any updates.
- `atl1` is the only no-nyc east coast of US data center for digital ocean.  So from
  a latency minimization perspective it makes sense to stick with `nyc3`.
