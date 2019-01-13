# Terraforming GKE and Kubernetes

This is my demo of some sharp edges when using the kubernetes provider alongside
the google provider. In this example, I make a global network and two Kubernetes
(k8s) clusters, both of which run a hello-world http server.

## Things that work

1.  The infrastructure spins up just fine.

## Mostly works

1.  If I change the zone of one of the clusters, terraform gets to the intended
    state after two runs, but I suspect this is mostly coincidental.

    On the first run it tears down the GKE cluster but none of its k8s contents,
    which makes it seem like the provider is being treated as a special case in
    the dependency graph when it shouldn't. It does successfully bring up the
    new cluster, but again none of its k8s contents. On the second run, it
    notices that the k8s contesnts are missing and successfully provisions them.

    Note that the original k8s resources were never deprovisioned. This would
    lead to strange Bad Things if there were any state that persisted from a k8s
    resource after a GKE cluster is deleted from underneath it. Thankfully (but
    not helpful for my example) in this case the GKE cluster deprovisioned all
    its contents before going away.

    Keep in mind, however, this edge-case will apply to *any* dependent provider
    whose module's parameters change. GKE and k8s are incidental here, and I
    feel sure that in the broader world there will exist a case where this
    slight incorrectness ill be quite damaging.
