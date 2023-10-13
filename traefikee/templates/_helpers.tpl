{{/*
Expand the name of the chart.
*/}}
{{- define "traefikee-helm-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "traefikee-helm-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "traefikee-helm-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Generates image name.
*/}}
{{- define "traefikee-helm-chart.image-name" -}}
  {{- with .Values.image }}
    {{- printf "%s/%s:%s" .registry .repository (.tag | default $.Chart.AppVersion) }}
  {{- end }}
{{- end }}

{{/*
Generates initContainer image name.
*/}}
{{- define "traefikee-helm-chart.initContainer-image-name" -}}
  {{- with .Values.initImage }}
    {{- printf "%s/%s:%s" .registry .repository .tag }}
  {{- end }}
{{- end }}

{{/*
Generates common labels.
*/}}
{{- define "common.labels" -}}
app: traefikee
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
release: {{ .Values.cluster }}
{{- end }}

{{/*
Generates or load registry token.
*/}}
{{- define "traefikee-helm-chart.registry-token" -}}
{{/* tokenSecretRef is provided, load it */}}
  {{- $tokenStr := "" }}
  {{- if eq (.Values.registry).manualTokenSecret true }}
    {{- if not (empty (.Values.registry).tokenSecretRef) }}
      {{- $tokenNS := .Release.Namespace }}
      {{- if not (empty (.Values.registry.tokenSecretRef).namespace) }}
        {{- $tokenNS := .Values.registry.tokenSecretRef.namespace }}
      {{- end }}

      {{- if empty (.Values.registry.tokenSecretRef).name }}
        {{- fail "ERROR: registry.tokenSecretRef needs at least secret name to be specified !"}}
      {{- end }}

      {{- $tokenSecret := (lookup "v1" "Secret" $tokenNS (.Values.registry.tokenSecretRef).name) }}
      {{- $tokenSecretData := (get $tokenSecret "data") | default dict }}
      {{- $tokenStr = (get $tokenSecretData "token" | b64dec ) | default "" }}
      {{- if eq $tokenStr "" }}
        {{- fail (printf "ERROR: failed to lookup token from secret %s/%s" $tokenNS (.Values.registry.tokenSecretRef.name))}}
      {{- end }}
    {{- end }}
  {{- else if not (empty (.Values.registry).tokenSecret) }}
    {{- $tokenStr = (.Values.registry).tokenSecret | default dict }}
  {{- else }} {{/* generate a random string */}}
    {{- $tokenStr = randAlphaNum 10 }}
  {{- end }}
{{- printf "%s" $tokenStr | nospace | b64enc }}
{{- end }}
