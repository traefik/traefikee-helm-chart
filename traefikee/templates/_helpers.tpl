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
{{- printf "%s:%s" .Values.image.name (.Values.image.tag | default .Chart.AppVersion) }}
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
Generates registry token.
*/}}
{{- define "traefikee-helm-chart.registry-token" -}}
{{- $tokenSecret := (lookup "v1" "Secret" .Release.Namespace (print .Values.cluster "-registry-token")) | default dict }}
{{- $tokenSecretData := (get $tokenSecret "data") | default dict }}
{{- $tokenStr := (get $tokenSecretData "token" | b64dec ) | default "" }}
{{- if eq $tokenStr "" }}
{{- $tokenStr = randAlphaNum 10 }}
{{- end }}
{{- printf "%s" $tokenStr | nospace | b64enc }}
{{- end }}
