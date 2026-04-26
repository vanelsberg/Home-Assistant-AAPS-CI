# HomeAsistant AAPS_CI Integration V2

2026-04-25: Version 2.0 (Major update)

- Impoved Installation process by moving AAPS CI integrations to a package
- Additional integration with the GitHub API (make sure to edit/update the file secrets.yaml for your environment!)

[HA Dashboard](https://github.com/vanelsberg/Home-Assistant-AAPS-CI/blob/main/doc/HA-AAPS-CI-dashboard.png)

Home Assistant integration of AAPS_CI (start button, status cards). This integration has two parts:

- Enable starting the AndroidAPS "browserbuild" workflow for the AAPSA development branch either manually or through automation. To use this feature the AAPS CI workflow option must be anabled.
  See AndroidAPS Documentation on [Browser build](https://wiki.aaps.app/en/latest/SettingUpAaps/BrowserBuild.html)

- Monitor Github on status of latest or new commits
  Tis can also enble starting automated build on new commits
   
Integration as described below was developed and tested for Home Assistant running in Docker.

# Prerequisites

- AAPS Web build is setup and working from github.
- Home Asistant version 2025.8 or later running on **Linux** or **Docker**.
- Terminal sudo access to the server running Home Assistant.

# Installation

Clone the content of this repository to a temporary location. Then copy the following directory to your Home Assistent installation to the HA config directory,

### Packages and files
- **config/AAPS_CI**.   (bash scripts)
- **config/packages**.  (HA packages)
- **config/support**.   (HA support files)

### Secrets
Create or edit the file secrets.xml in the HA directory and add the folowing lines. 
For detauilss see the file secrets.yaml in this repository:

    aaps_ci_access_token_header: "Bearer <Your AAPS CI Personal token>"
    aaps_ci_access_token_ha: "<Your AAPS CI Personal token>"
    github_commits_url: "https://api.github.com/repos/nightscout/AndroidAPS/commits?sha=dev"

- The token was defined when setting up AAPS-CI browser build.
- The github_commits_url point to the AAPS development branch.

# HA configuration.yaml

Make sure the following line are present. Add them when necessairy:

    homeassistant:
    packages: !include_dir_named packages

    automation: !include automations.yaml
    script: !include scripts.yaml
    scene: !include scenes.yaml

## Bash scripts

Your dashboard will not work without proper scrips. On your Home Asistant server, test by running the following scripts without errors.

**Note**:

    The bash scripts make use of the "jq" command (you can optionally install using 'sudo apt install jq')

Start with configuring and running the bash scripts in the confi/AAPS-CI directory from the ubuntu/linux commandline to verify the connection to GitHub:

1. Edit the config/AAPS-CI/_build.config_ file for your repoistory and owner name.
2. Run ./ci_workflows.sh to find your WORKFLOW_ID for the WORKFLOW_NAME (see details below)
3. Edit the build.config for your WORKFLOW_ID
4. Test run ./status.sh to find a list of latest CI runs (providing you did already run at least one CI build using GitHub)
5. Test run ./sync_with_upstream.sh to sync your forked repository with the upstream AAPS repoistory
6. Test run ./build.sh to start an AAPS CI build and verify it is running by checking github activity

After copying, configuring and testing the necessay files as described, restart Home Assistant and verify it is running as expected.

**Note**:

    The bash scripts can be used anytime to build from the Ubuntu commandline or for instance through a cron/systemd schedule.

### Additional details on configuring the scrips: _build.config_

You will need your Git workflow ID for "Branche CI". To retrieve you can the following "curl" command:

    curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
        https://api.github.com/repos/OWNER/REPO/actions/workflows

_Or alternatively you can use the _ci_workflows.sh_ script (recommended)._

Now change the _build.config_ file for your situation:

    # Forked repro and workflow ID
    OWNER=<Your forked repo owner name>
    REPO=<You forked repro name>
    WORKFLOW_ID=123456789

    # What to build
    OPT_BUILDVARIANT=fullRelease
    BRANCH="dev"

# HA Dashboard

**Make sure to validate your changes through the HA "developer tools" dashboard:**

- Click "Check configuration" (and when OK) "restart".
- Your new integration should now become active.

Create a new HA Dashboard:

1. Goto HA Settings and click the "+Add dashboard" button.
2. Select "New dashboard from scratch", name it to the name of your choice and then create it.
3. In HA open your new dashboard and click the "Edit dashboard" option.
4. Select the option "Raw configuration editor".
5. Replace the YAML definition with the YAML definition for AAPS-CI
    from the file _support/Development_Dashboard.yaml_.
6. Save and close the dashboard

To validate your configuration goto the HA "developer tools" dashboard:

1. Click "Check configuration" (and when OK) "restart".
2. Your new Dashboard should now become active.

Try starting a new build. There will be some delay before the Dashboard will start showing build status.

You can validate through GitHub if the CI build task while it is running to completion in the same way it would when starting it from GitHub directly.

# Automations:

1. Goto HA Settings and click the "Automations & scenes
2. Add a new basic/empty automation and save it
3. Edit the new automation by using the RAW yaml editor and paste the content of the file _support/schedule_AAPS-CI.yaml_
4. Save and close the automation
5. You can now open the automation from HA and change or disable/enable depending on your preferences.
