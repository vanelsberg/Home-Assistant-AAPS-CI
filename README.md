# HomeAsistant AAPS_CI Integration

[HA Dashboard](https://github.com/vanelsberg/Home-Assistant-AAPS-CI/blob/main/doc/HA-AAPS-CI-dashboard.png)

Home Assistant integration of AAPS_CI (start button, status card). This integration enables you to start the AndroidAPS "browserbuild" workflow. To user this the AAPS CI workflow option must be anabled.

See AndroidAPS Documentation on [Browser build](https://wiki.aaps.app/en/latest/SettingUpAaps/BrowserBuild.html)


## Installation

Clone the content of this repo to the "config" sub directory of your Home Assistent installation at the location

    **config/AAPS_CI**

# HA Configuration

## config/AAPS-CI/_config.sh_

You will need your workflow ID for "AAPS CI"

To retrieve you can the following "curl" command:

    curl -H "Authorization: token YOUR_GITHUB_TOKEN" \
        https://api.github.com/repos/OWNER/REPO/actions/workflows

    Or alternatively you can use the _ci_workflows.sh_ script.


### Change the _config.sh_ file for your situation: ###

    # Forked repro and workflow ID
    OWNER=vanelsberg<Your forked repo owner name>
    REPO=<You forked repro name>
    WORKFLOW_ID=123456789

    # What to build
    OPT_BUILDVARIANT=fullRelease
    BRANCH="dev"


## config/_secrets.yaml_

Add the following secrets (_Note that the token is use twice!_)

    aaps_ci_access_token_header: "Bearer <Your AAPS CI Personal token>"
    aaps_ci_access_token_ha: "<Your AAPS CI Personal token>"


## config/AAPS-CI/_configuration.yaml_

Add the following (sensor, template, shell command, script)

    sensor:
    - platform: rest
        name: AndroidAPS Workflow Status
        resource: https://api.github.com/repos/<YOUR_GITHUB_OWNER_NAME>/<YOUR_GITHUB_FORKEDREPO_NAME>/actions/workflows/180834796/runs
        headers:
        Authorization: !secret aaps_ci_access_token_header
        value_template: "{{ value_json.workflow_runs[0].status }}"
        json_attributes_path: "$.workflow_runs[0]"
        json_attributes:
        - created_at
        - status
        - conclusion

    template:
    - sensor:
        - name: "AndroidAPS Workflow Created At"
            state: "{{ state_attr('sensor.androidaps_workflow_status', 'created_at') }}"
        - name: "AndroidAPS Workflow Conclusion"
            state: "{{ state_attr('sensor.androidaps_workflow_status', 'conclusion') }}"

    shell_command:
    start_github_aaps_ci: 'bash /config/AAPS-CI/build.sh'

    script:
    trigger_github_aaps_ci:
        alias: "Start GitHub AAPS CI"
        sequence:
        - service: shell_command.start_github_aaps_ci


# HA Dashboard

With the above configuration you should be able to add an AAPS CI status card and button to your HA Dashbaord:

## Status

1. Add an "entity" card to your Dashboard
2. Edit the cards .YAML by using the "SHOW CODE EDITOR" button

        type: entities
        entities:
        - entity: sensor.androidaps_workflow_created_at
            name: Created At
            icon: mdi:electron-framework
        - entity: sensor.androidaps_workflow_status
            name: Status
            secondary_info: last-changed
            icon: mdi:electron-framework
        - entity: sensor.androidaps_workflow_conclusion
            name: Conclusion
            secondary_info: last-changed
            icon: mdi:electron-framework
        title: AAPS-CI Web Build
        state_color: true
        grid_options:
        columns: 12
        rows: 4


## Button

1. Add a "button" to your Dashboard
2. Edit the button .YAML by using the "SHOW CODE EDITOR" button
3. Replace its default .YAML with this

        show_name: true
        show_icon: true
        type: button
        entity: sensor.androidaps_workflow_status
        name: Start CI Run
        tap_action:
        action: call-service
        service: script.trigger_github_aaps_ci
        grid_options:
        columns: 6
        rows: 4
        show_state: true
        icon: mdi:electron-framework
