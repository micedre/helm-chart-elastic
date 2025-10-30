{{/*
Expand the name of the chart.
*/}}
{{- define "elasticsearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "elasticsearch.fullname" -}}
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
{{- define "elasticsearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "elasticsearch.labels" -}}
helm.sh/chart: {{ include "elasticsearch.chart" . }}
{{ include "elasticsearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "elasticsearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elasticsearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Elasticsearch selector labels
*/}}
{{- define "elasticsearch.esSelectorLabels" -}}
app.kubernetes.io/name: {{ include "elasticsearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: elasticsearch
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "elasticsearch.serviceAccountName" -}}
{{- if .Values.elasticsearch.serviceAccount.create }}
{{- default (include "elasticsearch.fullname" .) .Values.elasticsearch.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.elasticsearch.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Kibana fullname
*/}}
{{- define "kibana.fullname" -}}
{{- printf "%s-kibana" (include "elasticsearch.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Kibana labels
*/}}
{{- define "kibana.labels" -}}
helm.sh/chart: {{ include "elasticsearch.chart" . }}
{{ include "kibana.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Kibana selector labels
*/}}
{{- define "kibana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "elasticsearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: kibana
{{- end }}

{{/*
Generate elasticsearch password
*/}}
{{- define "elasticsearch.password" -}}
{{- if .Values.elasticsearch.security.password }}
{{- .Values.elasticsearch.security.password }}
{{- else }}
{{- randAlphaNum 16 }}
{{- end }}
{{- end }}

{{/*
Elasticsearch cluster name
*/}}
{{- define "elasticsearch.clusterName" -}}
{{- printf "%s-cluster" (include "elasticsearch.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Elasticsearch master service name (headless)
*/}}
{{- define "elasticsearch.masterService" -}}
{{- printf "%s-headless" (include "elasticsearch.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
