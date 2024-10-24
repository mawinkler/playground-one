locals {
  passthrough_conf = <<-EOT
    stream {
      log_format basic '$remote_addr [$time_local] '
                  '$protocol $status $bytes_sent $bytes_received '
                  '$session_time "$upstream_addr" '
                  '"$upstream_bytes_sent" "$upstream_bytes_received" "$upstream_connect_time"';

      access_log /var/log/nginx/_SERVICE.log basic;
      error_log  /var/log/nginx/_SERVICE-error.log;

      upstream dsm {
        server ${var.dsm_private_ip}:4119
        max_fails=3
        fail_timeout=10s;
      } server {
        listen 4119;
        proxy_pass dsm;
        proxy_next_upstream on;
      }
    }
  EOT

  userdata_linux = templatefile("${path.module}/userdata_linux.tftpl", {
  })
}
