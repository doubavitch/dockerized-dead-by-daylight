# Dockerized 'Dead By Daylight' Data Visualization

## How to run this pipeline

- Clone this repository and work within the folder created locally:

```
git@github.com:doubavitch/dockerized-dead-by-daylight.git
cd dockerized-dead-by-daylight
```

- Build the Docker image:
  
```
docker build -t dead-by-daylight .
```

Note that this step might take a while the first time (around 40 minutes). This is most due to the use of renv::restore(), a rather time-consuming command.




## Requirements

