{{/*
Create chart version as used by the chart label.
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "labels" -}}
helm.sh/chart: {{ include "chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/environment: {{ .Values.env }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.name }}
app.kubernetes.io/component: {{ .Release.Name }}
{{- end }}

{{/*
HTTP health check probe
*/}}
{{- define "httpHealthProbe" -}}
httpGet:
  path: /api/v1/hello
  port: http
{{- end -}}
