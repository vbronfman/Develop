# Foobar

Project deploys rady-to-go monitoring stack comprises of:
- "exposer" server to expose metrics (Python3)
- Prometheus aka Scraper, URL http://scraper:9090
- Grafana aka Viewer with predefined dashboard to present all the metrics.


## Installation

Unpack archive with your archiver of choice. Project requires host with Docker Composer.
Bundle employs following ports :


Have to name file provisioning/datasources/datasources.yaml - otherwise doesn’t work for me


## Usage
To start bundle : 
1.Change current dir to "eBay challenge" folder of unpacked archive.
2.Run command
docker-compose up -d


## Roadmap
Add proper installer
Add processing of SIGTERM signal  to exposer (on docker-compose down)


## License