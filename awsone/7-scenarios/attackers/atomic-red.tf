# #############################################################################
# Deploy the vulnerable web application atomic-red-falco
# Runs every hour
# #############################################################################
resource "kubernetes_cron_job_v1" "demo" {
  depends_on = [kubernetes_namespace_v1.attackers_namespace]
  metadata {
    name = "atomic-red-falco"
  }

  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "0 * * * *"
    timezone                      = "Etc/UTC"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10

    job_template {
      metadata {
        name = "atomic-red-falco"
        labels = {
          app = "atomic-red-falco"
        }
      }
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {
            labels = {
              app = "atomic-red-falco"
            }
          }
          spec {
            container {
              name    = "atomic-red-falco"
              image   = "mawinkler/atomic_red_docker:latest"
              command = ["pwsh", "/root/RunTests.ps1", "T1003.008", "T1014", "T1027.002", "T1036.003", "T1037.004", "T1053.003", "T1070.002", "T1070.003", "T1087.001", "T1201", "T1543.002", "T1546.004", "T1547.006", "T1548.001", "T1552.004", "T1556.003", "T1560.001", "T1562.004", "T1574.006"]
              security_context {
                privileged = true
              }
            }
          }
        }
      }
    }
  }
}
