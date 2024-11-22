# Scenario: Helper Tools for Deep Security to Vision One Migration

## What the Migration Tool is Missing

The migration from Deep Security to Vision One Server & Workload Protection is made possible by the integrated migration tool. This can easily migrate the common objects, policies, cloud accounts and computers. However, other individual configurations such as smart folders, computer groups or scheduled tasks are not migrated.

The workflow described in this scenario is composed from the following steps:

1. Create Computer Group structure in SWP
2. Create Smart Folder structure in SWP
3. Migrate the Common Objects, Policies, and Computers with the official Migration Tool
4. Merge the Scheduled Tasks

!!! information "Additional Repository"

    This scenario uses an additional GitHub repository [ds-swp-migration-tools](https://github.com/mawinkler/ds-swp-migration-tools).

## Prerequisites

If you want to play through this scenario using Playground Ones Deep Security follow the Prerequisites described in You can follow [Migrate Deep Security to Vision One](ds-migrate.md/#prerequisites) for the deployment. ***Don't do the actual migration now, just meet the requirements!***

## Get the Tools

Get the code:

```sh
cd ${ONEPATH}
git clone https://github.com/mawinkler/ds-swp-migration-tools.git
cd ds-swp-migration-tools
```

## Create Computer Group structure in SWP

- Set environment variable `API_KEY_SWP` with the API key of the Server & Workload Security instance to use.
- Set environment variable `API_KEY_DS` with the API key of the Deep Security instance to use.
- Adapt the constants in between
  `# HERE`
  and
  `# /HERE`
  within the scripts to your requirements.
  ```sh
  # HERE
  REGION_SWP = "us-1."  # Examples: de-1. sg-1.
  API_BASE_URL_DS = "https://3.76.217.110:4119/api/"
  # /HERE
  ```

Change to the directory of the desired script and install dependencies:

```sh
cd groups-and-folders

python3 -m venv venv && source venv/bin/activate

pip install -r requirements.txt
```

Get help:

```sh
./groups-and-folders.py --help
```

```sh
usage: python3 groups-and-folders.py [-h] [--listgroups TYPE] [--mergegroups TYPE] [--listfolders TYPE] [--mergefolders TYPE]

List and merge Computer Groups and Smart Folders in between DS and SWP

options:
  -h, --help           show this help message and exit
  --listgroups TYPE    list computer groups (TYPE=ds|swp)
  --mergegroups TYPE   merge computer groups from given source (TYPE=ds|swp)
  --listfolders TYPE   list smart folders (TYPE=ds|swp)
  --mergefolders TYPE  list smart folders from given source (TYPE=ds|swp)
```

Merge the computer group hierarchy into SWP. Existing groups will neither be overwritten nor deleted.

```sh
# Merge Computer Groups from DS with SWP
$ ./groups-and-folders.py --mergegroups ds

# List Computer Groups in SWP
$ ./groups-and-folders.py --listgroups swp

```

## Create Smart Folder structure in SWP

Still in the `groups-and-folders` run:

```sh
# Merge Smart Folders from DS with SWP
$ ./groups-and-folders.py --mergefolders ds

# List Smart Folders in SWP
$ ./groups-and-folders.py --listfolders swp
```

## Migrate the Common Objects, Policies, and Computers with the official Migration Tool

Do the Deep Security migration using the official migration tool. You can follow [Migrate Deep Security to Vision One](ds-migrate.md/#migration-workflow) for a guided migration.

The migrated policies will get a suffix generated (e.g. ` (2024-11-14T16:26:36Z 10.0.0.84)`). Use this suffix as the `--policysuffix` for `scheduled-tasks.py` in the next step.

## Merge the Scheduled Tasks

```sh
cd ../scheduled-tasks

python3 -m venv venv && source venv/bin/activate

pip install -r requirements.txt
```

Get help:

```sh
./scheduled-tasks.py --help
```

```sh
usage: python3 scheduled-tasks.py [-h] [--listtasks TYPE] [--mergetasks TYPE] [--policysuffix POLICYSUFFIX] [--taskprefix TASKPREFIX]

List and merge Scheduled Tasks in between DS and SWP

options:
  -h, --help            show this help message and exit
  --listtasks TYPE      list scheduled tasks (TYPE=ds|swp)
  --mergetasks TYPE     merge scheduled tasks from given source (TYPE=ds|swp)
  --policysuffix POLICYSUFFIX
                        Optional policy name suffix.
  --taskprefix TASKPREFIX
                        Optional task name prefix.
```

> ***Notes:***
> - Contacts with the predefined role of 'Auditor' are automatically created if they do not exist in the target environment.
> - Administrators will not be migrated since the API-Key of SWP does not have the necessary permissions to create Administrators.

```sh
# Merge Scheduled Tasks from DS with SWP
$ ./scheduled-tasks.py --mergetasks ds --policysuffix " (2024-11-14T16:26:36Z 10.0.0.84)" --taskprefix "DS"

# List Scheduled Tasks in SWP
$ ./scheduled-tasks.py --listtasks swp
```

🎉 Success 🎉
