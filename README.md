# Introduction

This is a base layer for common code needed to run the
[CIS Benchmark for Kubernetes][cis-benchmark]. Charms that include this layer
will have a `cis-benchmark` action included in their builds. This action
invokes the [kube-bench][kube-bench] utiity to test if Kubernetes components
comply with the benchmark recommendations.

## Usage

Run the benchmark action on a charm that includes this layer. For example:

```bash
juju run-action --wait etcd/0 cis-benchmark
```

By default, the action will display a summary of any issues found as well as
the command that was executed on the unit. A `report` command is included
to faciliate transfering the full benchmark report to a local machine for
analysis.

```yaml
results:
  cmd: /home/ubuntu/kube-bench/kube-bench -D /home/ubuntu/kube-bench/cfg-ck
    --benchmark cis-1.5 --noremediations --noresults run --targets etcd
  report: juju scp etcd/0:/home/ubuntu/kube-bench-results/results-text-49681_7h .
  summary: |
    == Summary ==
    7 checks PASS
    0 checks FAIL
    0 checks WARN
    0 checks INFO
status: completed
```

## Parameters

The following parameters can be adjusted to change the default action behavior.
See the descriptions in `actions.yaml` for additional supported values beyond
the defaults.

### apply

When a failure is detected, this action can attempt to automatically fix it.
This parameter is `none` by default, meaning the action will not attempt to
apply any automatic remediations.

### config

Specify an archive of custom configuration scripts to use during the benchmark.
This parameter is set by default to an archive that is known to work with
snap-related components.

### release

Specify the `kube-bench` release to install and run. This parameter is set by
default to a release that is known to work with snap-related components.

## Example Use Case

Benchmark the `kubernetes-worker` charm using a custom configuration archive:

```bash
juju run-action --wait kubernetes-worker/0 cis-benchmark \
  config='https://github.com/charmed-kubernetes/kube-bench-config/archive/cis-1.5.zip'
```

```yaml
results:
  cmd: /home/ubuntu/kube-bench/kube-bench -D /home/ubuntu/kube-bench/cfg-ck
    --benchmark cis-1.5 --noremediations --noresults run --targets node
  report: juju scp kubernetes-worker/0:/home/ubuntu/kube-bench-results/results-text-nmmlsvy3 .
  summary: |
    == Summary ==
    16 checks PASS
    4 checks FAIL
    3 checks WARN
    0 checks INFO
status: completed
```

Attempt to apply all known fixes to failing benchmark tests using the same
configuration archive:

```bash
juju run-action --wait kubernetes-worker/0 cis-benchmark \
  apply='dangerous' \
  config='https://github.com/charmed-kubernetes/kube-bench-config/archive/cis-1.5.zip'
```

```yaml
results:
  cmd: /home/ubuntu/kube-bench/kube-bench -D /home/ubuntu/kube-bench/cfg-ck
    --benchmark cis-1.5 --noremediations --noresults run --targets node
  report: juju scp kubernetes-worker/0:/home/ubuntu/kube-bench-results/results-json-dozp8j3z .
  summary: Applied 4 remediations. Re-run with "apply=none" to generate a new report.
status: completed
```

Re-run the earlier action to verify previous failures have been fixed:

```bash
juju run-action --wait kubernetes-worker/0 cis-benchmark \
  config='https://github.com/charmed-kubernetes/kube-bench-config/archive/cis-1.5.zip'
```

```yaml
results:
  cmd: /home/ubuntu/kube-bench/kube-bench -D /home/ubuntu/kube-bench/cfg-ck
    --benchmark cis-1.5 --noremediations --noresults run --targets node
  report: juju scp kubernetes-worker/0:/home/ubuntu/kube-bench-results/results-text-4agbktbf .
  summary: |
    == Summary ==
    20 checks PASS
    0 checks FAIL
    3 checks WARN
    0 checks INFO
status: completed
```

## Removing Applied Remediations

This action does not track individual remediations that it applies. However, it
does support removing all configuration that it may have set in a charm's
`unitdata.kv`. To clear this data from a unit, set the `apply` parameter to
`reset`:

```bash
juju run-action --wait kubernetes-worker/0 cis-benchmark \
  apply='reset'
```

```yaml
results:
  summary: Reset is complete. Re-run with "apply=none" to generate a new report.
status: completed
```

<!-- LINKS -->

[cis-benchmark]: https://www.cisecurity.org/benchmark/kubernetes/
[kube-bench]: https://github.com/aquasecurity/kube-bench
