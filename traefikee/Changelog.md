# Change Log

## 3.0.2  ![AppVersion: v2.10.7](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.7&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-12-21

* chore(deps): update docker.io/traefik/traefikee docker tag to v2.10.7
* change chart version following ingressClass add
* add Ingressclass

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 07b4125..8608fac 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -17,6 +17,13 @@ initImage:
   repository: busybox
   tag: "1.36.1"
 
+# -- To create a default IngressClass for TraefikEE, set `enabled: true` below:
+# It should also be set on k8s providers in static configuration
+ingressClass:
+  enabled: false
+  isDefaultClass: false
+  name:
+
 # log:
 #  level: DEBUG
 #  format:
@@ -120,8 +127,10 @@ controller:
       providers:
         kubernetesIngress:
           allowEmptyServices: true
+          ingressClass:
         kubernetesCRD:
           allowEmptyServices: true
+          ingressClass:
 
 #  serviceLabels:
 #    foo: bar
```

## 3.0.1  ![AppVersion: v2.10.6](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.6&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-12-06

* chore: release v3.0.1 with Traefik Enterprise v2.10.6
* chore(deps): update docker.io/traefik/traefikee docker tag to v2.10.6


## 3.0.0  ![AppVersion: v2.10.5](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.5&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-11-23

* fix: :see_no_evil: allow user to run proxy on priviledged ports
* fix: :boom: change default traefik port and make it configurable
* feat: :card_file_box: configmap superseeds inline for staticConfig
* chore(release): :rocket: publish v3.0.0

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 34b537a..07b4125 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -108,8 +108,10 @@ controller:
 #      key: "static.yml"
     content: |
       entrypoints:
+        traefik:
+          address: ":9000"
         web:
-          address: ":7000"
+          address: ":7080"
         websecure:
           http:
             tls: {}
@@ -168,6 +170,8 @@ proxy:
       cpu: "1000m"
       memory: "1Gi"
   ports:
+    - name: traefik
+      port: 9000
     - name: http
       port: 7080
     - name: https
@@ -244,6 +248,8 @@ proxy:
       port: traefik
     initialDelaySeconds: 2
     periodSeconds: 5
+  securityContext:
+    runAsUser: 65532
 
 #  serviceLabels:
 #    foo: bar
```

## 2.0.0  ![AppVersion: v2.10.5](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.5&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-10-25

* fix: probes and ports on secured deployment
* fix: don't set plugin registry CLI when it's disabled
* feat: provide default HA values
* feat: inline static configuration
* feat: improve security on controller & registry
* feat: improve security defaults on proxy
* feat: allow to deploy without registry
* feat: add support for topology spread constraints on the controller
* feat: add optional hpa for proxy
* feat: :boom: rename image.name and image.initContainer
* feat: :boom: add readiness and liveness on all pods
* docs: add missing changelog entry for last release
* chore(release): publish v2.0.0
* chore(deps): update docker.io/traefik/traefikee docker tag to v2.10.5
* chore(deps): update docker.io/helmunittest/helm-unittest docker tag to v3.12.3
* chore(deps): update docker.io/busybox docker tag to v1.36.1

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 68e2a9e..34b537a 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -5,13 +5,17 @@ cluster: "default"
 #   - name: regcred
 
 image:
-  name: traefik/traefikee
+  registry: docker.io
+  repository: traefik/traefikee
   # defaults to appVersion
   tag: ""
   pullPolicy: IfNotPresent
-  initContainer:
-    name: busybox
-    tag: "1.31.1"
+
+# Used to run initContainers
+initImage:
+  registry: docker.io
+  repository: busybox
+  tag: "1.36.1"
 
 # log:
 #  level: DEBUG
@@ -19,6 +23,8 @@ image:
 #  file:
 
 registry:
+  # When disabled, plugins cannot be used
+  enabled: true
   # To disable affinity at all set this value to null
   affinity:
     nodeAffinity:
@@ -94,10 +100,27 @@ controller:
                   values:
                     - controllers
             topologyKey: "kubernetes.io/hostname"
-#  staticConfig:
+  # Static Configuration can be set within values OR
+  # from an external ConfigMap. Not both.
+  staticConfig:
 #    configMap:
 #      name: traefik-config
 #      key: "static.yml"
+    content: |
+      entrypoints:
+        web:
+          address: ":7000"
+        websecure:
+          http:
+            tls: {}
+          address: ":7443"
+      ping: {}
+      providers:
+        kubernetesIngress:
+          allowEmptyServices: true
+        kubernetesCRD:
+          allowEmptyServices: true
+
 #  serviceLabels:
 #    foo: bar
 #  serviceAnnotations:
@@ -120,6 +143,16 @@ controller:
 #        secretKeyRef:
 #          name: foo
 #          key: BAR
+# # This example topologySpreadConstraints forces the scheduler to put traefikee controller pods
+# # on nodes where no other traefikee controller pods are scheduled.
+#  topologySpreadConstraints:
+#    - labelSelector:
+#        matchLabels:
+#          app: traefikee
+#          component: controllers
+#      maxSkew: 1
+#      topologyKey: kubernetes.io/hostname
+#      whenUnsatisfiable: DoNotSchedule
 ## Tolerations allow the scheduler to schedule pods with matching taints.
   tolerations: []
 
@@ -134,12 +167,19 @@ proxy:
     limits:
       cpu: "1000m"
       memory: "1Gi"
-  serviceType: LoadBalancer
   ports:
+    - name: http
+      port: 7080
+    - name: https
+      port: 7443
+  serviceType: LoadBalancer
+  servicePorts:
     - name: http
       port: 80
+      targetPort: http
     - name: https
       port: 443
+      targetPort: https
 # # Specify Static IP of cloud provider LB
 #  loadBalancerIP: "1.2.3.4"
 
@@ -164,11 +204,47 @@ proxy:
                   values:
                     - proxies
             topologyKey: "kubernetes.io/hostname"
-#  readinessProbe:
-#    tcpSocket:
-#      port: http
-#    initialDelaySeconds: 2
-#    periodSeconds: 5
+
+  autoscaling:
+    # -- Create HorizontalPodAutoscaler object.
+    enabled: false
+    # minReplicas: 1
+    # maxReplicas: 10
+    # metrics:
+    # - type: Resource
+    #   resource:
+    #     name: cpu
+    #     target:
+    #       type: Utilization
+    #       averageUtilization: 60
+    # - type: Resource
+    #   resource:
+    #     name: memory
+    #     target:
+    #       type: Utilization
+    #       averageUtilization: 60
+    # behavior:
+    #   scaleDown:
+    #     stabilizationWindowSeconds: 300
+    #     policies:
+    #     - type: Pods
+    #       value: 1
+    #       periodSeconds: 60
+
+## Those probes need for ping to be enabled in static config
+  readinessProbe:
+    httpGet:
+      path: /ping
+      port: traefik
+    initialDelaySeconds: 2
+    periodSeconds: 5
+  livenessProbe:
+    httpGet:
+      path: /ping
+      port: traefik
+    initialDelaySeconds: 2
+    periodSeconds: 5
+
 #  serviceLabels:
 #    foo: bar
 #  serviceAnnotations:
```

## 1.15.0  ![AppVersion: v2.10.4](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-08-23

* feat: allows to unset `spec.replicas` on proxy
* feat: allows to set spec.strategy on proxy
* chore: add LICENSE, PR template, Changelog and Release Notes
* chore(deps): use renovate on this repo

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 0b939a6..68e2a9e 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -124,6 +124,8 @@ controller:
   tolerations: []
 
 proxy:
+  # Can be set to null when using HPA, in order to avoid conflict between HPA
+  # and this Chart on replicas.
   replicas: 2
   resources:
     requests:
@@ -206,6 +208,12 @@ proxy:
 #      whenUnsatisfiable: DoNotSchedule
 ## Tolerations allow the scheduler to schedule pods with matching taints.
   tolerations: []
+#  strategy:
+#    # -- Customize updateStrategy: RollingUpdate or OnDelete
+#    type: RollingUpdate
+#    rollingUpdate:
+#      maxUnavailable: 0
+#      maxSurge: 1
 
 # priorityClassName will be set on all pods.
 priorityClassName: ""
```

## 1.14.2  ![AppVersion: v2.10.4](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-08-03

* bump EE version


## 1.14.1  ![AppVersion: v2.10.2](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-06-22

* Release TraefikEE v2.10.2


## 1.14.0  ![AppVersion: v2.10.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-06-19

* Add toleration support

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index eb83307..0b939a6 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -59,6 +59,8 @@ registry:
 #    namespace: othernamespace
 ## Set the registry token directly in Values
 #  tokenSecret: "NJ00yx60K+Wm1yufuBM6fLq3fVKcv44RvBsVGiH40+U="
+## Tolerations allow the scheduler to schedule pods with matching taints.
+  tolerations: []
 
 
 controller:
@@ -118,6 +120,8 @@ controller:
 #        secretKeyRef:
 #          name: foo
 #          key: BAR
+## Tolerations allow the scheduler to schedule pods with matching taints.
+  tolerations: []
 
 proxy:
   replicas: 2
@@ -200,6 +204,8 @@ proxy:
 #      maxSkew: 1
 #      topologyKey: kubernetes.io/hostname
 #      whenUnsatisfiable: DoNotSchedule
+## Tolerations allow the scheduler to schedule pods with matching taints.
+  tolerations: []
 
 # priorityClassName will be set on all pods.
 priorityClassName: ""
```

## 1.13.0  ![AppVersion: v2.10.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-05-25

* adding static loadbalancer IP field in proxy service

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 26cd9f5..eb83307 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -134,6 +134,8 @@ proxy:
       port: 80
     - name: https
       port: 443
+# # Specify Static IP of cloud provider LB
+#  loadBalancerIP: "1.2.3.4"
 
   # To disable affinity at all set this value to null
   affinity:
```

## 1.12.0  ![AppVersion: v2.10.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-05-02

* add topologySpreadConstraint to proxy deployment

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index d9be1d1..26cd9f5 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -188,6 +188,16 @@ proxy:
 #    minAvailable: 1
 #    maxUnavailable: 1
 # terminationGracePeriodSeconds: 30
+# # This example topologySpreadConstraints forces the scheduler to put traefikee proxy pods
+# # on nodes where no other traefikee pods are scheduled.
+#  topologySpreadConstraints:
+#    - labelSelector:
+#        matchLabels:
+#          app: traefikee
+#          component: proxies
+#      maxSkew: 1
+#      topologyKey: kubernetes.io/hostname
+#      whenUnsatisfiable: DoNotSchedule
 
 # priorityClassName will be set on all pods.
 priorityClassName: ""
```

## 1.11.0  ![AppVersion: v2.10.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.10.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-04-28

* Release TraefikEE v2.10.1


## 1.10.0  ![AppVersion: v2.9.2](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-04-27

* feat: improve traefikee helm chart
* bump chart version

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 382108b..d9be1d1 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -63,6 +63,14 @@ registry:
 
 controller:
   replicas: 1
+  resources:
+    requests:
+      cpu: "100m"
+      memory: "128Mi"
+    limits:
+      cpu: "1000m"
+      memory: "4Gi"
+
   # To disable affinity at all set this value to null
   affinity:
     nodeAffinity:
@@ -113,6 +121,13 @@ controller:
 
 proxy:
   replicas: 2
+  resources:
+    requests:
+      cpu: "400m"
+      memory: "256Mi"
+    limits:
+      cpu: "1000m"
+      memory: "1Gi"
   serviceType: LoadBalancer
   ports:
     - name: http
@@ -174,6 +189,9 @@ proxy:
 #    maxUnavailable: 1
 # terminationGracePeriodSeconds: 30
 
+# priorityClassName will be set on all pods.
+priorityClassName: ""
+
 mesh:
   enabled: false
   kubedns: false
```

## 1.9.1  ![AppVersion: v2.9.2](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-04-12

* Update TraefikEE to v2.9.2


## 1.9.0  ![AppVersion: v2.9.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-04-12

* Registry token

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index de3f006..382108b 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -40,7 +40,6 @@ registry:
                   values:
                     - registry
             topologyKey: "kubernetes.io/hostname"
-
 #   serviceLabels:
 #     foo: bar
 #   serviceAnnotations:
@@ -53,7 +52,14 @@ registry:
 #     foo: bar
 #   podAnnotations:
 #     foo: bar
-#   manualTokenSecret: true
+## Needed if you setup the registry token manually before deploying TraefikEE
+#  manualTokenSecret: true
+#  tokenSecretRef:
+#    name: secret
+#    namespace: othernamespace
+## Set the registry token directly in Values
+#  tokenSecret: "NJ00yx60K+Wm1yufuBM6fLq3fVKcv44RvBsVGiH40+U="
+
 
 controller:
   replicas: 1
```

## 1.8.0  ![AppVersion: v2.9.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-04-03

* feat: allow setting custom pod affinity

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 9ea43c5..de3f006 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -18,7 +18,29 @@ image:
 #  format:
 #  file:
 
-# registry:
+registry:
+  # To disable affinity at all set this value to null
+  affinity:
+    nodeAffinity:
+      requiredDuringSchedulingIgnoredDuringExecution:
+        nodeSelectorTerms:
+          - matchExpressions:
+            - key: kubernetes.io/os
+              operator: In
+              values:
+                - linux
+    podAntiAffinity:
+      preferredDuringSchedulingIgnoredDuringExecution:
+        - weight: 100
+          podAffinityTerm:
+            labelSelector:
+              matchExpressions:
+                - key: component
+                  operator: In
+                  values:
+                    - registry
+            topologyKey: "kubernetes.io/hostname"
+
 #   serviceLabels:
 #     foo: bar
 #   serviceAnnotations:
@@ -35,6 +57,27 @@ image:
 
 controller:
   replicas: 1
+  # To disable affinity at all set this value to null
+  affinity:
+    nodeAffinity:
+      requiredDuringSchedulingIgnoredDuringExecution:
+        nodeSelectorTerms:
+          - matchExpressions:
+            - key: kubernetes.io/os
+              operator: In
+              values:
+                - linux
+    podAntiAffinity:
+      preferredDuringSchedulingIgnoredDuringExecution:
+        - weight: 100
+          podAffinityTerm:
+            labelSelector:
+              matchExpressions:
+                - key: component
+                  operator: In
+                  values:
+                    - controllers
+            topologyKey: "kubernetes.io/hostname"
 #  staticConfig:
 #    configMap:
 #      name: traefik-config
@@ -70,6 +113,28 @@ proxy:
       port: 80
     - name: https
       port: 443
+
+  # To disable affinity at all set this value to null
+  affinity:
+    nodeAffinity:
+      requiredDuringSchedulingIgnoredDuringExecution:
+        nodeSelectorTerms:
+          - matchExpressions:
+            - key: kubernetes.io/os
+              operator: In
+              values:
+                - linux
+    podAntiAffinity:
+      preferredDuringSchedulingIgnoredDuringExecution:
+        - weight: 100
+          podAffinityTerm:
+            labelSelector:
+              matchExpressions:
+                - key: component
+                  operator: In
+                  values:
+                    - proxies
+            topologyKey: "kubernetes.io/hostname"
 #  readinessProbe:
 #    tcpSocket:
 #      port: http
```

## 1.7.0  ![AppVersion: v2.9.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2023-01-23

* Add terminationGracePeriodSeconds to the values

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 26169fd..9ea43c5 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -101,6 +101,7 @@ proxy:
 #  podDisruptionBudget:
 #    minAvailable: 1
 #    maxUnavailable: 1
+# terminationGracePeriodSeconds: 30
 
 mesh:
   enabled: false
```

## 1.6.1  ![AppVersion: v2.9.1](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-12-15

* Release v2.9.1


## 1.6.0  ![AppVersion: v2.9.0](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-11-29

* Allow customization of initContainer image

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 636d86b..26169fd 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -9,6 +9,9 @@ image:
   # defaults to appVersion
   tag: ""
   pullPolicy: IfNotPresent
+  initContainer:
+    name: busybox
+    tag: "1.31.1"
 
 # log:
 #  level: DEBUG
```

## 1.5.0  ![AppVersion: v2.9.0](https://img.shields.io/static/v1?label=AppVersion&message=v2.9.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-11-28

* Release TraefikEE v2.9.0


## 1.4.2  ![AppVersion: v2.8.4](https://img.shields.io/static/v1?label=AppVersion&message=v2.8.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-11-10

* fix: app version


## 1.4.1  ![AppVersion: 2.8.4](https://img.shields.io/static/v1?label=AppVersion&message=2.8.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-11-08

* Move CRDs directory


## 1.4.0  ![AppVersion: 2.8.4](https://img.shields.io/static/v1?label=AppVersion&message=2.8.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-11-02

* add pdb for proxy and make pdb compatible with 1.25

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index bc72689..636d86b 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -94,6 +94,10 @@ proxy:
 #        secretKeyRef:
 #          name: foo
 #          key: BAR
+#  # minAvailable or maxUnavailable (default value is maxUnavailable: 1)
+#  podDisruptionBudget:
+#    minAvailable: 1
+#    maxUnavailable: 1
 
 mesh:
   enabled: false
```

## 1.3.0  ![AppVersion: 2.8.4](https://img.shields.io/static/v1?label=AppVersion&message=2.8.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-25

* Add `imagePullSecrets` property

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 7f0493f..bc72689 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -1,6 +1,9 @@
 # Default values for Traefik Enterprise
 cluster: "default"
 
+# imagePullSecrets:
+#   - name: regcred
+
 image:
   name: traefik/traefikee
   # defaults to appVersion
```

## 1.2.7  ![AppVersion: 2.8.4](https://img.shields.io/static/v1?label=AppVersion&message=2.8.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-24

* Update TraefikEE to v2.8.4


## 1.2.6  ![AppVersion: 2.8.3](https://img.shields.io/static/v1?label=AppVersion&message=2.8.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-21

* Fix environment variables parsing

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 04e81c7..7f0493f 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -48,7 +48,13 @@ controller:
 #  additionalArguments:
 #    - --foo=bar
 #  env:
-#    foo: bar
+#    - name: FOO
+#      value: 1
+#    - name: BAR
+#      valueFrom:
+#        secretKeyRef:
+#          name: foo
+#          key: BAR
 
 proxy:
   replicas: 2
@@ -78,7 +84,13 @@ proxy:
 #  additionalArguments:
 #    - --foo=bar
 #  env:
-#    foo: bar
+#    - name: FOO
+#      value: 1
+#    - name: BAR
+#      valueFrom:
+#        secretKeyRef:
+#          name: foo
+#          key: BAR
 
 mesh:
   enabled: false
```

## 1.2.5  ![AppVersion: 2.8.3](https://img.shields.io/static/v1?label=AppVersion&message=2.8.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-19

* Allow passing environment variables for controller and regular proxies

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 8cf39b4..04e81c7 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -47,6 +47,8 @@ controller:
 #    foo: bar
 #  additionalArguments:
 #    - --foo=bar
+#  env:
+#    foo: bar
 
 proxy:
   replicas: 2
@@ -75,6 +77,8 @@ proxy:
 #    foo: bar
 #  additionalArguments:
 #    - --foo=bar
+#  env:
+#    foo: bar
 
 mesh:
   enabled: false
```

## 1.2.4  ![AppVersion: 2.8.3](https://img.shields.io/static/v1?label=AppVersion&message=2.8.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-05

* Update Traefik v2.8 CRDs


## 1.2.3  ![AppVersion: 2.8.3](https://img.shields.io/static/v1?label=AppVersion&message=2.8.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-10-03

* Update TraefikEE to v2.8.3


## 1.2.2  ![AppVersion: 2.8.2](https://img.shields.io/static/v1?label=AppVersion&message=2.8.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-09-20

* Release v2.8.2


## 1.2.1  ![AppVersion: 2.8.1](https://img.shields.io/static/v1?label=AppVersion&message=2.8.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-09-19

* Release TraefikEE v2.8.1


## 1.2.0  ![AppVersion: 2.8.0](https://img.shields.io/static/v1?label=AppVersion&message=2.8.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-09-13

* Update TraefikEE to v2.8.0


## 1.1.4  ![AppVersion: 2.7.3](https://img.shields.io/static/v1?label=AppVersion&message=2.7.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-09-08

* Update TraefikEE to v2.7.3


## 1.1.3  ![AppVersion: 2.7.2](https://img.shields.io/static/v1?label=AppVersion&message=2.7.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-08-26

* Update TraefikEE to v2.7.2


## 1.1.2  ![AppVersion: 2.7.1](https://img.shields.io/static/v1?label=AppVersion&message=2.7.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-08-23

* Update TraefikEE to v2.7.1


## 1.1.1  ![AppVersion: 2.7.0](https://img.shields.io/static/v1?label=AppVersion&message=2.7.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-08-05

* Update Traefik Mesh manifests


## 1.1.0  ![AppVersion: 2.7.0](https://img.shields.io/static/v1?label=AppVersion&message=2.7.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-07-05

* Update TraefikEE to v2.7.0


## 1.0.2  ![AppVersion: 2.6.5](https://img.shields.io/static/v1?label=AppVersion&message=2.6.5&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-06-29

* Update TraefikEE to v2.6.5


## 1.0.1  ![AppVersion: 2.6.4](https://img.shields.io/static/v1?label=AppVersion&message=2.6.4&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-05-30

* Update TraefikEE to v2.6.4


## 1.0.0  ![AppVersion: 2.6.1](https://img.shields.io/static/v1?label=AppVersion&message=2.6.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-05-18

* Support additional arguments, labels and annotations

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index a16de7f..8cf39b4 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -1,27 +1,90 @@
 # Default values for Traefik Enterprise
 cluster: "default"
 
-registry:
-  token: ""
+image:
+  name: traefik/traefikee
+  # defaults to appVersion
+  tag: ""
+  pullPolicy: IfNotPresent
 
-proxy:
-  image:
-    name: traefik/traefikee
-    # defaults to appVersion
-    tag: ""
-    pullPolicy: IfNotPresent
-  proxies: 2
-  controllers: 1
-  staticConfig:
+# log:
+#  level: DEBUG
+#  format:
+#  file:
+
+# registry:
+#   serviceLabels:
+#     foo: bar
+#   serviceAnnotations:
+#     foo: bar
+#   statefulSetLabels:
+#     foo: bar
+#   statefulSetAnnotations:
+#     foo: bar
+#   podLabels:
+#     foo: bar
+#   podAnnotations:
+#     foo: bar
+#   manualTokenSecret: true
+
+controller:
+  replicas: 1
+#  staticConfig:
 #    configMap:
-#    configMapKey: "static.yaml"
+#      name: traefik-config
+#      key: "static.yml"
+#  serviceLabels:
+#    foo: bar
+#  serviceAnnotations:
+#    foo: bar
+#  statefulSetLabels:
+#    foo: bar
+#  statefulSetAnnotations:
+#    foo: bar
+#  podLabels:
+#    foo: bar
+#  podAnnotations:
+#    foo: bar
+#  additionalArguments:
+#    - --foo=bar
+
+proxy:
+  replicas: 2
+  serviceType: LoadBalancer
   ports:
     - name: http
       port: 80
     - name: https
       port: 443
+#  readinessProbe:
+#    tcpSocket:
+#      port: http
+#    initialDelaySeconds: 2
+#    periodSeconds: 5
+#  serviceLabels:
+#    foo: bar
+#  serviceAnnotations:
+#    foo: bar
+#  deploymentLabels:
+#    foo: bar
+#  deploymentAnnotations:
+#    foo: bar
+#  podLabels:
+#    foo: bar
+#  podAnnotations:
+#    foo: bar
+#  additionalArguments:
+#    - --foo=bar
 
 mesh:
   enabled: false
   kubedns: false
   clusterDomain: "cluster.local"
+#  daemonSetLabels:
+#    foo: bar
+#  daemonSetAnnotations:
+#    foo: bar
+#  podLabels:
+#    foo: bar
+#  podAnnotations:
+#    foo: bar
```

## 0.2.1  ![AppVersion: 2.6.1](https://img.shields.io/static/v1?label=AppVersion&message=2.6.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-04-07

* Update TraefikEE to v2.6.1


## 0.2.0  ![AppVersion: 2.6.0](https://img.shields.io/static/v1?label=AppVersion&message=2.6.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-03-11

* Update TraefikEE to v2.6.0


## 0.1.11  ![AppVersion: 2.5.8](https://img.shields.io/static/v1?label=AppVersion&message=2.5.8&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-03-09

* Update TraefikEE to v2.5.8


## 0.1.10  ![AppVersion: 2.5.7](https://img.shields.io/static/v1?label=AppVersion&message=2.5.7&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-03-08

* Fix token indempotency for helm template using values

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 1e61b18..a16de7f 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -1,6 +1,9 @@
 # Default values for Traefik Enterprise
 cluster: "default"
 
+registry:
+  token: ""
+
 proxy:
   image:
     name: traefik/traefikee
```

## 0.1.9  ![AppVersion: 2.5.7](https://img.shields.io/static/v1?label=AppVersion&message=2.5.7&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-02-21

* Update TraefikEE to v2.5.7


## 0.1.8  ![AppVersion: 2.5.6](https://img.shields.io/static/v1?label=AppVersion&message=2.5.6&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-02-09

* Load plugin registry token via secret


## 0.1.7  ![AppVersion: 2.5.6](https://img.shields.io/static/v1?label=AppVersion&message=2.5.6&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2022-02-02

* Update TraefikEE to v2.5.6


## 0.1.6  ![AppVersion: 2.5.3](https://img.shields.io/static/v1?label=AppVersion&message=2.5.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-12-23

* Fix value for proxy Deployment replicas


## 0.1.5  ![AppVersion: 2.5.3](https://img.shields.io/static/v1?label=AppVersion&message=2.5.3&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-12-23

* Update TraefikEE to v2.5.3


## 0.1.4  ![AppVersion: 2.5.2](https://img.shields.io/static/v1?label=AppVersion&message=2.5.2&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-12-17

* Update TraefikEE version to 2.5.2


## 0.1.3  ![AppVersion: 2.5.1](https://img.shields.io/static/v1?label=AppVersion&message=2.5.1&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-11-24

* Traefikee 2.5.1 Release


## 0.1.2  ![AppVersion: 2.5.0](https://img.shields.io/static/v1?label=AppVersion&message=2.5.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-11-23

* Update controller StatefulSet release selector


## 0.1.1  ![AppVersion: 2.5.0](https://img.shields.io/static/v1?label=AppVersion&message=2.5.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-11-19

* test: fix tests due to values.yaml change

### Default value changes

```diff
diff --git a/traefikee/values.yaml b/traefikee/values.yaml
index 0ba2f26..1e61b18 100644
--- a/traefikee/values.yaml
+++ b/traefikee/values.yaml
@@ -10,7 +10,7 @@ proxy:
   proxies: 2
   controllers: 1
   staticConfig:
-#    configMap: 
+#    configMap:
 #    configMapKey: "static.yaml"
   ports:
     - name: http
```

## 0.1.0  ![AppVersion: 2.5.0](https://img.shields.io/static/v1?label=AppVersion&message=2.5.0&color=success&logo=) ![Kubernetes: >= 1.14.0-0](https://img.shields.io/static/v1?label=Kubernetes&message=%3E%3D+1.14.0-0&color=informational&logo=kubernetes) ![Helm: v3](https://img.shields.io/static/v1?label=Helm&message=v3&color=informational&logo=helm)

**Release date:** 2021-11-10

* feat: implement helm chart for traefikee

### Default value changes

```diff
# Default values for Traefik Enterprise
cluster: "default"

proxy:
  image:
    name: traefik/traefikee
    # defaults to appVersion
    tag: ""
    pullPolicy: IfNotPresent
  proxies: 2
  controllers: 1
  staticConfig:
#    configMap: 
#    configMapKey: "static.yaml"
  ports:
    - name: http
      port: 80
    - name: https
      port: 443

mesh:
  enabled: false
  kubedns: false
  clusterDomain: "cluster.local"
```

---
Autogenerated from Helm Chart and git history using [helm-changelog](https://github.com/mogensen/helm-changelog)
