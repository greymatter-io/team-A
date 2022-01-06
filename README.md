# Team A - Grey Matter GitOps Sync Repo

This repo models the directory structure for a Grey Matter GitOps sync repo.

Grey Matter mesh configuration objects are defined in CUE, and are patterned after the mesh configurations bootstrapped by Grey Matter Operator.

## Project Layout

- **manifests**: Kubernetes manifests to apply with kubectl (not managed by greymatter sync)
- **cue.mod**: Defines a CUE module for importing CUE dependencies
- **default.cue**: Templates that contain values shared across mesh objects of the same type
- **<service-name>.cue**: Mesh objects that customize behavior for each service in the mesh.

## Manually running greymatter sync

While the GitOps sync loop is meant to be run from within a sync container, you can also run `greymatter sync` with this repo cloned to your local machine.

Provided that your greymatter CLI configuration file has the proper `api` and `catalog` values for connecting to each Grey Matter core service, run the following at the root of this repo to sync the mesh objects defined in this repo:

```bash
greymatter sync --cue
```
