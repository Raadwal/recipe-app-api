FROM python:3.9-alpine3.13
# Whoever will be mantaining this docker image
LABEL maintainer="https://github.com/Raadwal"

# Recommended when running python in docker container
# It's tell python that you don't want to buffer the output
ENV PYTHONUNBUFFERED 1

# Copying files to the docker image
COPY requirements.txt /tmp/requirements.txt
COPY requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# Working directory - default directory from which our commands will run on the docker image
WORKDIR /app
# Exposing port 8000 to machine on which is container running
EXPOSE 8000


# This block run the command on the alpine image we are using (1-st line) when we are builduing our image
# Virtual environment in docker image grants another layer of safety when we dependecies
# We checkes if we are running container in development we will install dev dependencies, otherwise we will not install it
# We are deleting any unnecesery file we crated - it's good practice to keep image as leightweighet as possible
# It's making deploying application faster
# adduser command is adding new user in our image - it's good practice not to use root user for safety purposes

# It's updating value from docker compose to true so by default we are not running it in development mode
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
      then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Updates environment variables, so whenever we run any Python commands it will automaticlly run from out virtual environment
ENV PATH="/py/bin:$PATH"

# Specify the user that we are switching to, every command before that was run as root user
USER django-user