# Use the specified Rocker image
FROM rocker/r-ver:4.4.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libglpk-dev \
    libxml2-dev \
    libcairo2-dev \
    libgit2-dev \
    default-libmysqlclient-dev \
    libpq-dev \
    libsasl2-dev \
    libsqlite3-dev \
    libssh2-1-dev \
    libxtst6 \
    libcurl4-openssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    unixodbc-dev \
    wget && \
    apt-get clean

# Install Quarto
RUN wget https://github.com/quarto-dev/quarto-cli/releases/download/v1.6.39/quarto-1.6.39-linux-arm64.deb -O /home/quarto.deb && \
    apt-get install --yes /home/quarto.deb && \
    rm /home/quarto.deb

RUN apt-get install libmpfr-dev

# Create a project directory and copy files
RUN mkdir /project
COPY . /project
WORKDIR /project

RUN R -e "install.packages(c('renv', 'targets', 'tarchetypes', 'knitr', 'rmarkdown'))"

RUN R -e "renv::restore()"

# Run the targets pipeline
RUN R -e "targets::tar_make()"

# Expose port 4200 for Quarto preview
EXPOSE 4200

# Start Quarto preview on all network interfaces
CMD ["quarto", "preview", "Death_is_not_an_escape.qmd", "--host", "0.0.0.0", "--port", "4200"]