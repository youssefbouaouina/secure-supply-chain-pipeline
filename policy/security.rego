package main

import rego.v1

# 1. Images must be pinned to a real tag, never :latest.
deny contains msg if {
  some container in input.spec.template.spec.containers
  endswith(container.image, ":latest")
  msg := sprintf("container %q uses the :latest tag", [container.name])
}

# 2. No privileged containers.
deny contains msg if {
  some container in input.spec.template.spec.containers
  container.securityContext.privileged == true
  msg := sprintf("container %q is privileged", [container.name])
}

# 3. No host network.
deny contains msg if {
  input.spec.template.spec.hostNetwork == true
  msg := "pod uses hostNetwork"
}

# 4. CPU and memory limits are mandatory.
deny contains msg if {
  some container in input.spec.template.spec.containers
  not container.resources.limits.cpu
  msg := sprintf("container %q has no CPU limit", [container.name])
}

deny contains msg if {
  some container in input.spec.template.spec.containers
  not container.resources.limits.memory
  msg := sprintf("container %q has no memory limit", [container.name])
}

# 5. Must run as non-root (pod-level or container-level).
deny contains msg if {
  not input.spec.template.spec.securityContext.runAsNonRoot == true
  some container in input.spec.template.spec.containers
  not container.securityContext.runAsNonRoot == true
  msg := sprintf("container %q may run as root", [container.name])
}

# 6. Root filesystem must be read-only.
deny contains msg if {
  some container in input.spec.template.spec.containers
  not container.securityContext.readOnlyRootFilesystem == true
  msg := sprintf("container %q has a writable root filesystem", [container.name])
}

# 7. RuntimeDefault seccomp profile.
deny contains msg if {
  not input.spec.template.spec.securityContext.seccompProfile.type == "RuntimeDefault"
  some container in input.spec.template.spec.containers
  msg := sprintf("container %q does not set seccompProfile RuntimeDefault", [container.name])
}

# 8. All Linux capabilities dropped.
deny contains msg if {
  some container in input.spec.template.spec.containers
  not "ALL" in object.get(container.securityContext, "capabilities", {}).drop
  msg := sprintf("container %q does not drop ALL capabilities", [container.name])
}
