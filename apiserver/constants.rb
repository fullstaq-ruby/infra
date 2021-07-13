# frozen_string_literal: true

GCLOUD_PROJECT = 'fullstaq-ruby'
KUBERNETES_NAMESPACE = 'fullstaq-ruby'
KUBERNETES_CLUSTER_NAME = 'fullstaq-ruby-autopilot'
KUBERNETES_CLUSTER_REGION = 'us-east4'

# Must be smaller than the Google Cloud Run max timeout.
WEB_SERVER_RESTART_TIMEOUT = '5m'
