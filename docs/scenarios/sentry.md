# Sentry

To create findings and scan with Sentry run

```sh
$PGPATH/terraform-awsone/0-scripts/create-findings.sh
```

Feel free to have a look on the script above, but in theory it should prepare six findings for Sentry and two Workbenches in Vision One.

To trigger Sentry scans for any instance run (example):

```sh
# INSTANCE=<INSTANCE_ID> sentry-trigger-ebs-scan
INSTANCE=$(terraform output -raw public_instance_ip_web1) sentry-trigger-ebs-scan
```

The scan results should show up in your Cloud One Central console.
