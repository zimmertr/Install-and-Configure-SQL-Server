# Install and Configure SQL Server

## Summary

This script will automatically install and Configure a SQL Server 2012 Instance for you on a Windows Server 2012 instance.

It is capable of performing the following actions:

* Installing Google Chrome.
* Mounting SQL Server installation media.
* Installing SQL Server from a response file. (Template provided).
* Interactively configuring or deploying your provided file template.
* Installing .NET Framework 3.5.
* Enabling SQL Server to listen on all TCP/IP interfaces that are attached to the instance.
* Configuring the Static and Dynamic port numbers associated with each TCP/IP Interface
* Customizing the maximum and minimum amount of memory allocated to the SQL Server instances.
* Creating sub directories for automatic backups tasks.
* Configuring `mssql` and `sqlagent` services to startup as _Automatic (Delayed)_ instead of _Automatic_ to ensure `NETLOGON` service has already started.
* Restarting SQL Server to apply the above changes.
* Printing a deployment summary of the status of the instance and your configurations.

## Instructions

1. Place SQL Server installation media on your desktop and rename it as `sql_installer.iso`
2. Place Response File template on your desktop and rename it as `sql_server_response_file.ini`.
3. (Optionally) Configure response file in your text editor of choice. Alternatively, this can be done interactively from the script.
4. Launch the script: `.\install-sql_server.ps1` in ISE. 
