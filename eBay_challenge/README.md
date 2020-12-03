# Foobar

Project deploys ready-to-go monitoring stack of services comprises of:
- "exposer" server to expose dummy metrics 
- Prometheus server aka scraper
- Grafana aka viewer with predefined dashboard 'EXPOSER' to represent metrics.



## Installation

- Unpack archive with your archiver of choice. Project requires host with Docker Composer.
- Run ./setup_and_run.sh for initial setup.

## Usage
To start bundle : 
1. Change current directory to "eBay_challenge" folder of unpacked archive.
2. Run command ./setup_and_run.sh.
3. Script suggests to assign ports to expose. This allows to avoid port clashing on local host.
CAUTION! It is recommended to keep ports of SCRAPER and VIEWER intact: due both employs 
well-known ports and changing would result in integrity issue.
4. Select ports. Hit 'Enter' to keep defaults. 
5. Script requests conformation to proceed with build and launch  services.
6. Script launches `docker-compose up -d`


## Configuration

Configuration step is done by bash script `setup_and_run.sh`. 
Configuration implies:
- exposed ports assignment
- creation and cofiguration of Prometheus's targets


During configuration step content of following files are modified:
`.env `- environment variables for build; in this case - exposed ports per service.
`prometheus/prometheus.yaml ` - updated with list of targets
`prometheus/targets/*.json` - Prometheus targets; files to create if do not exist

Predefined configuration files; please do not change unless you're absolutely positive:
	`grafana/provisioning/datasources/datasources.yaml` - refers URL 'scraper:9090' datasource; I did not figured out the way to change the default
	`grafana/provisioning/dashboards/dashboards.yaml`   - specify the need to import dashboards from disk
	`grafana/dashboards/eBay_dashboard.json`            - "Exposer" dashboard
	`exposer/Dockerfile`
	`docker-compose.yaml`
	

## Build

Build procedure parses docker-compose.yaml and builds images in corresponding.
Docker Compose employs `.env` file to set environment variables available upon build. 
It grants flexibility in terms of managing the content of docker-compose.yaml.
These variable then at the disposal of build for nested services via Dockerfile.

### EXPOSER
Resource to produce monitoring metrics. Deployed into container with Python3 installed.
'Exposer' more or less straight copy of https://github.com/prometheus/client_python
Usage:
`python3 exposer.py <LISTEN_PORT>`

See content of `exposer/Dockerfile` for specifics about container properties.

#### Exposed metrics
'Exposer' thoughtfully exposes dummy metrics of the following type :
- Histogram 
- Gauge 
- Counter 

### SCRAPPER

An instance of Prometheus server.
Targets configured dynamically via <target>.json files during initial configuration step.
Files reside under `prometheus/targets` folder of the project. 
Configuration implies corresponding modification of `prometheus/prometheus.yaml` automatically.
File then deployed into container upon build.
Please refer for details about Prometheus configuration: https://prometheus.io/docs/guides/file-sd/

### VIEWER

Grafana server with custom configuration of datasource. 
Predefined dashboard 'EXPOSER' is under grafana/dashboards/eBay_dashboard.json eBay_dashboard 
Dashboard along with corresponding datasource than deployed upon build by 'provisioning' means of 
Grafana's .
See https://grafana.com/docs/grafana/latest/administration/provisioning/ for details.
File name `datasources.yaml` of provisioning/datasources/datasources.yaml seems 
prescribed - otherwise doesn’t work for me.



## Roadmap
- set internal network properly
- assign proper labels to metrics
- rid of volumes mounted to Docker host. Can be done with custom Dockerfiles' for Prometheus 
  and Grafana
- Add to exposer  processing of SIGTERM signal (on docker-compose down) to rid of delay to kill
- Review using of 'latest' Docker images in favor of custom ones.
- configuration script ./setup_and_run.sh pretty lacks error validations




## License