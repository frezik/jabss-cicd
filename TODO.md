Minimum Viable
==============
* Log to a streaming, machine-readable and human-readable format
** It gonna be YAML. The last entry can be an array, and you just append to it
* A way to securely manage auth
* Handling auth
** Run an SSH command on a remote server
** Send a message to Slack



And Then . . . 
==============
* Auth daemon
** Send email
** Curl w/token or basic auth
* Command to display details about a log
** Success/failure
** Total run time
** Run time of sections
** Complete output
* Ways to run pipelines
** Manually
** Cron
** Triggered by external thing (e.g. git commit on a repo)
* Run script on some machine in the JABSS cluster
* If we must, a way to view logs on a web site
