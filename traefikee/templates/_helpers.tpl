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
{{- printf "%s:%s" .Values.proxy.image.name (.Values.proxy.image.tag | default (printf "v%s" .Chart.AppVersion)) }}
{{- end }}

{{/*
Generates common labels
*/}}
{{- define "common.labels" -}}
app: traefikee
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
app.kubernetes.io/managed-by: {{ .Release.Service}}
app.kubernetes.io/instance: {{ .Release.Name}}
release: {{ .Values.cluster }}
{{- end }}
