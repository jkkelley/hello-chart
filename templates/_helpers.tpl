{{- define "hello-chart.name" -}}
hello
{{- end -}}

{{- define "hello-chart.fullname" -}}
{{ include "hello-chart.name" . }}
{{- end -}}

{{- define "hello-chart.labels" -}}
app.kubernetes.io/name: {{ include "hello-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}