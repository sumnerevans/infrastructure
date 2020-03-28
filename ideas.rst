* For all databases that are backed up, have a "before service start" which goes
  and restores from the backup if a certain ``.no_backup_restore`` file is
  present.

  This will allow for me to blow away the entire machine, and it will restore
  the database backups automatically before the services start.

* Data is backed up to B2/S3.

* Move Pictures over to storage in S3.
