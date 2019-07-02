#!/usr/bin/env bats

load _helpers

@test "meshGateway/Deployment: disabled by default" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "false" ]
}

@test "meshGateway/Deployment: enabled with meshGateway.enabled true" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      . | tee /dev/stderr |
      yq 'length > 0' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "meshGateway/Deployment: annotations can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.annotations=key: value' \
      . | tee /dev/stderr |
      yq -r '.metadata.annotations.key' | tee /dev/stderr)
  [ "${actual}" = "value" ]
}

@test "meshGateway/Deployment: replicas defaults to 2" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.replicas' | tee /dev/stderr)
  [ "${actual}" = "2" ]
}

@test "meshGateway/Deployment: replicas can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.replicas=3' \
      . | tee /dev/stderr |
      yq -r '.spec.replicas' | tee /dev/stderr)
  [ "${actual}" = "3" ]
}

@test "meshGateway/Deployment: affinity defaults to one per node" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey' | tee /dev/stderr)
  [ "${actual}" = "kubernetes.io/hostname" ]
}

@test "meshGateway/Deployment: affinity can be overridden" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.affinity=key: value' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.affinity.key' | tee /dev/stderr)
  [ "${actual}" = "value" ]
}

@test "meshGateway/Deployment: tolerations can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.tolerations=- key: value' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.tolerations[0].key' | tee /dev/stderr)
  [ "${actual}" = "value" ]
}

@test "meshGateway/Deployment: hostNetwork can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.hostNetwork=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.hostNetwork' | tee /dev/stderr)
  [ "${actual}" = "true" ]
}

@test "meshGateway/Deployment: dnsPolicy can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.dnsPolicy=ClusterFirst' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.dnsPolicy' | tee /dev/stderr)
  [ "${actual}" = "ClusterFirst" ]
}

@test "meshGateway/Deployment: envoy image has default" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].image' | tee /dev/stderr)
  [ "${actual}" = "envoyproxy/envoy:v1.10" ]
}

@test "meshGateway/Deployment: envoy image can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.imageEnvoy=new/image' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].image' | tee /dev/stderr)
  [ "${actual}" = "new/image" ]
}

@test "meshGateway/Deployment: resources can be set" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.resources=requests: yadayada' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].resources.requests' | tee /dev/stderr)
  [ "${actual}" = "yadayada" ]
}

@test "meshGateway/Deployment: wanAddress.useNodeIP" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.wanAddress.useNodeIP=true' \
      --set 'meshGateway.wanAddress.port=4444' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].command[2]' | tee /dev/stderr)
  [[ "${actual}" =~ '-wan-address="${HOST_IP}:4444"' ]]
}

@test "meshGateway/Deployment: wanAddress.useNodeName" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.wanAddress.useNodeIP=false' \
      --set 'meshGateway.wanAddress.useNodeName=true' \
      --set 'meshGateway.wanAddress.port=4444' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].command[2]' | tee /dev/stderr)
  [[ "${actual}" =~ '-wan-address="${NODE_NAME}:4444"' ]]
}

@test "meshGateway/Deployment: wanAddress.host" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.wanAddress.useNodeIP=false' \
      --set 'meshGateway.wanAddress.useNodeName=false' \
      --set 'meshGateway.wanAddress.host=myhost' \
      --set 'meshGateway.wanAddress.port=4444' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.containers[0].command[2]' | tee /dev/stderr)
  [[ "${actual}" =~ '-wan-address="myhost:4444"' ]]
}

@test "meshGateway/Deployment: can disable healthchecks" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.enableHealthChecks=false' \
      . | tee /dev/stderr)

  local liveness=$(echo "${actual}" | yq -r '.spec.template.spec.containers[0].livenessProbe' | tee /dev/stderr)
  [ "${liveness}" = "null" ]
  local readiness=$(echo "${actual}" | yq -r '.spec.template.spec.containers[0].readinessProbe' | tee /dev/stderr)
  [ "${readiness}" = "null" ]
}

@test "meshGateway/Deployment: can set a nodeSelector" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'meshGateway.nodeSelector=key: value' \
      . | tee /dev/stderr |
      yq -r '.spec.template.spec.nodeSelector.key' | tee /dev/stderr)

  [ "${actual}" = "value" ]
}

@test "meshGateway/Deployment: global.BootstrapACLs" {
  cd `chart_dir`
  local actual=$(helm template \
      -x templates/mesh-gateway-deployment.yaml  \
      --set 'meshGateway.enabled=true' \
      --set 'global.bootstrapACLs=true' \
      . | tee /dev/stderr )
  local init_container=$(echo "${actual}" | yq -r '.spec.template.spec.initContainers[1].name' | tee /dev/stderr)
  [ "${init_container}" = "mesh-gateway-acl-init" ]

  local secret=$(echo "${actual}" | yq -r '.spec.template.spec.containers[0].env[3].name' | tee /dev/stderr)
  [ "${secret}" = "CONSUL_HTTP_TOKEN" ]
}

