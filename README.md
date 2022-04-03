# CI-CD-docker-flask
A CI/CD pipeline which deploys a docker image to ECR, lints the python code and pushes the updated image.

To build the docker image use the below command
docker build . --tag "name-of-image"

Define Your custom message using the CUSTOM_MESSAGE environment variable in the my-env.txt file
CUSTOM_MESSAGE="Any message you like"

To run and start the docker container pass the environment variable file to the container

docker run -p 5000:5000 --env-file my-env.txt "name-of-image"