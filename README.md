# HomeAsistant AAPS_CI Integration

[HA Dashboard](https://github.com/vanelsberg/Home-Assistant-AAPS-CI/blob/main/doc/HA-AAPS-CI-dashboard.png)

Home Assistant integration of AAPS_CI (start button, status card). This integration enables you to start the AndroidAPS "browserbuild" workflow. To user this the AAPS CI workflow option must be anabled.

See AndroidAPS Documentation on [Browser build](https://wiki.aaps.app/en/latest/SettingUpAaps/BrowserBuild.html)

Integration as described below was developed and tested for Home Assistant running in Docker.

#### Prerequisites

- AAPS Web build setup and working from github.
- Home Asistant version 2025.8 or later running on **Linux** or **Docker**.
- Terminal sudo access to the server running Home Assistant.

## Installation

Clone the content of this repo to a temporary location.
Then copy "AAPS_CI" directory of your Home Assistent installation at the config location    **config/AAPS_CI**.

# HA Configuration

## EDIT config/AAPS-CI/_build.config_

You will need your Git workflow ID for "Branche CI". To retrieve you can the following "curl" command:

    curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
        https://api.github.com/repos/OWNER/REPO/actions/workflows

    Or alternatively you can use the _ci_workflows.sh_ script.


### AAPS-CI: Change the _build.config_ file for your situation:

    # Forked repro and workflow ID
    OWNER=<Your forked repo owner name>
    REPO=<You forked repro name>
    WORKFLOW_ID=123456789

    # What to build
    OPT_BUILDVARIANT=fullRelease
    BRANCH="dev"

## HA EDIT config/_secrets.yaml_

Add the following secrets (_Note that the token is use twice!_)

    aaps_ci_access_token_header: "Bearer <Your AAPS CI Personal token>"
    aaps_ci_access_token_ha: "<Your AAPS CI Personal token>"

### AAPS-CI: Test the scripts

Your dashboard will not work without proper scrips. On your Home Asistant server, test by running the following scripts without errors.

_Note_: the scrips make use of the "jq" command (you can optionally install using 'sudo apt install jq')

    cd config/AAPS-CI

    # Show list of AAPS-CI workflows
    ./ci_workflow.sh

    # Show workflow status 
    ./status.sh

    # Start a new AAPS-CI build
    ./build.sh

    # Sync your AndroidAPS local frok with main
    ./sync_with_upstream.sh

    # Hint: see AAPS_CI.log for details

## HA EDIT config/_configuration.yaml_

Add the following sections (sensor, template, shell command, script) to your current HA configuration.
Then edit the values for <YOUR_GITHUB_OWNER_NAME> and <YOUR_GITHUB_FORKEDREPO_NAME> in the platform:rest section.

    sensor:
    - platform: rest
        name: AndroidAPS Workflow Status
        resource: https://api.github.com/repos/<YOUR_GITHUB_OWNER_NAME>/<YOUR_GITHUB_FORKEDREPO_NAME>/actions/workflows/<YOUR_AAPS_CI_WORKFLOWID>/runs
         .... [See configuration.xml]

    template:
    - sensor:
        - name: "AndroidAPS Workflow Created At"
            state: "{{ state_attr('sensor.androidaps_workflow_status', 'created_at') }}"
        .... [See configuration.xml]

    shell_command:
        .... [See configuration.xml]

    script:
    trigger_github_aaps_ci:
        .... [See configuration.xml]


# HA Dashboard

To create a new HA Dashboard:

	1. Goto HA Settings and click the "+Add dashboard" button.
	2. Select "New dashboard from scratch", name it to name of your choice and then create it.
	3. In HA open your new dashboard and click the "Edit dashboard" option.
	4. Select the option "Raw configuration editor".
	5. Replace the YAML definition with the YAML definition for AAPS-CI from the file AAPS_ci_dashboard.yaml).
	6. Save and close the dashboard

Now validate you chnages to the configuration.yaml file goto the HA "developer tools" dashboard:

- Click "Check configuration" (and when OK) "restart".
- Your new Dashboard should now become active.

## Raw YAML dashboard configuration for AAPS-CI:

  AAPS_ci_dashboard.yaml
