# API server

The API server is a service that allows performing limited management operations on the infrastructure. It mainly exists to securely allow the Server Edition's CI to tell Caddy about the fact that new packages have been deployed.

Presently, there is only one endpoint: `POST /admin/restart_web_server`. This endpoint initiates restarting of Caddy, but does not wait for it to finish.

## Calling the production instance

The production instance is deployed at https://apiserver-f7awo4fcoa-uk.a.run.app/. To call it, you need to include your Google Cloud identity token in the Authorization header.

```bash
curl -v -H "Authorization: Bearer $(gcloud auth print-identity-token)" https://apiserver-f7awo4fcoa-uk.a.run.app/
```

## Continuous deployment

New API server code changes, when pushed to master, are automatically deployed by the Infrastructure project's CI.
