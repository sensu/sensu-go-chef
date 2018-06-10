<!--
Hi there,

Thank you for opening an issue. Please note that we try to keep the issue tracker reserved for bug reports, feature requests, and RFCs. For general help please join us in our [community slack](https://slack.sensu.io) in the `#chef` channel.
-->

### Chef Version

<!--
Please include the version of `chef-client` you are running, for example:
```
$ chef-client --version
Chef: 14.2.0
```
-->

### Input

<!--
Please include the relevant snippets in your code where you call or change the behavior of the upstream code. This could include runlists, attributes (role, environment, cookbook, databag, etc), recipes, etc. Please redact anything sensitive for your protection. If the issue requires seeing the sensitive information you can indicate on the issue and a maintainer can have you send it to them via email encrypted via PGP.
-->

### Output

<!--
In order to expedite the speed of triage it is important that you give as much information as possible. Please include the relevant output which includes console, chef logs, and sensu logs. Please include any other relevant debug output such as showing process is running, api accepting/rejecting request, etc.
-->

### Impact

<!-- Explain the impact this issue had on your organization. This can include technical and non technical impact, urgency, etc. -->

### Expected Behavior

<!-- What should have happened? -->

### Actual Behavior

<!-- What actually happened? -->

### Steps to Reproduce your problem

<!--
Please include the required steps such as:
1. checkout a specific version (or commit) of the cookbook
1. Run `KITCHEN_LOCAL_YAML=.kitchen.dokken.yml bundle exec kitchen converge default-ubuntu-1604`
1. Run `KITCHEN_LOCAL_YAML=.kitchen.dokken.yml bundle exec kitchen login default-ubuntu-1604`
1. Run the following command inside the container/instance: `systemctl status sensu-agent`
-->
