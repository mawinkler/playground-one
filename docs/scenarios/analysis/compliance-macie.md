aws macie2 get-finding-statistics --region eu-central-1 --group-by resourcesAffected.s3Bucket.name
aws macie2 get-finding-statistics --region eu-central-1 --group-by type --finding-criteria criterion={resourcesAffected.s3Bucket.name={eq=pgo-cs-bucket-bv4snznf}}
aws macie2 list-findings --region eu-central-1 --finding-criteria criterion={resourcesAffected.s3Bucket.name={eq=pgo-cs-bucket-bv4snznf}}
aws macie2 get-findings --region eu-central-1 --finding-ids 6698f21db723ef8ba68d97a7a785da2d --query 'findings[*]'

aws macie2 list-findings --region eu-central-1 --finding-criteria criterion={resourcesAffected.s3Bucket.name={eq=pgo-satellite-pgo-cs-bucket-m8awmvfc}}
aws macie2 get-findings --region eu-central-1 --finding-ids d84264af1d3ebd2d3a9ffdc613b7011a --query 'findings[*]'
