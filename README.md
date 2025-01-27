# Dockerized 'Dead By Daylight' Data Visualization

## How to run this pipeline

- In your terminal, clone this repository and work within the folder created locally:

```
git clone git@github.com:doubavitch/dockerized-dead-by-daylight.git
cd dockerized-dead-by-daylight
```

- Launch Docker on your machine.

- Build the Docker image:
  
```
docker build -t dead-by-daylight .
```

Note that this step might take a while the first time (around 40 minutes). This is mostly due to the use of renv::restore(), a rather time-consuming command.

- Run the pipeline:

```
docker run --rm -p 4200:4200 dead-by-daylight
```

- Finally, in the browser of your choice, access the following url:

http://localhost:4200

You should now be accessing the Quarto Presentation reviewing my Data Visualization project based on the online game 'Dead by Daylight'.


## Requirements

You need to have Docker installed.

If that is not the case, visit the following website: https://www.docker.com/get-started/.
