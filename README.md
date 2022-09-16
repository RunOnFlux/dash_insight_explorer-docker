# DASH INSIGHT EXPLORER
<b> DOCKER IMAGE INCLUDES: </b>
- Dash Daemon
- Insight-API
- Insight-UI
- Dashcore-Node

<br>MongoDB installed separatly as independent component

### Environment Variables

To customize some properties of the container, the following environment
variables can be passed via the `-e` parameter (one for each variable).  Value
of this parameter has the format `<VARIABLE_NAME>=<VALUE>`.

| Variable       | Description                                  | Default |
|----------------|----------------------------------------------|---------|
|`DB_COMPONENT_NAME`| Name of mongo host for insight-api. | `fluxmongodb_dash_insight_explorer` |
 - Name of mongo continer must be same as `DB_COMPONENT_NAME`

v18.0.1
