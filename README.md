# CI-CD-docker-flask

A CI/CD pipeline which deploys a docker image to ECR, lints the python code and pushes the updated image.

## To build the docker image use the below command

### => docker build . --tag "name-of-image"

## Define Your custom message using the CUSTOM_MESSAGE environment variable in the my-env.txt file

#### CUSTOM_MESSAGE="Any message you like"

## To run and start the docker container pass the environment variable file to the container

### => docker run -p 5000:5000 --env-file my-env.txt "name-of-image"

## CI/CD using Github Actions

<p>
For the purpose of linting the codebase a github action named super-linter has been used for linting the entire codebases, the linter can handle
languages like python, javascript, yaml and many more.

# main.yaml

```

    name: Test and Deploy Image

    on:
    push:
        branches: [ main ]

    jobs:

    build:
        name: Lint code base
        runs-on: ubuntu-latest

        steps: 

        - name: Checkout the code
            uses: actions/checkout@v3

        - name: Lint the python code
            uses: github/super-linter/slim@v4
            env:
            VALIDATE_GITHUB_ACTIONS: false
    build-push-image:

        needs: build
        runs-on: ubuntu-latest

        steps:
        - name: Checkout the code
            uses: actions/checkout@v3

        - name: configure aws credentials
            uses: aws-actions/configure-aws-credentials@v1
            with:
            aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
            aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
            aws-region : ${{ secrets.AWS_REGION }}

        - name: login to amazon ecr
            id: login-ecr
            uses: aws-actions/amazon-ecr-login@v1

        - name: Build, tag, and push image to Amazon ECR
            env:
            ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
            ECR_REPOSITORY: flask-docker-web-app
            IMAGE_TAG: flask-docker-web-app
            run:  |
            docker build -t  ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .
            docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}

```

A workflow containing different jobs has been created, the jobs are discussed below:

<p>
<ol>
<li>Lint Code base</li>
<ol>
<li>Checkout the repository for workflow access</li>
<li>Uses the super-linter action from the github marketplace and scans the code for any linting errors</li>
</ol>
<li>build and push docker image to amazon ecr
<ol>
<li>This job requires the code to be linted first</li>
<li>Configure aws credentials by providing access key and secret key as secrets in github actions</li>
<li>Build the image and publish to private ECR repository</li>
</ol>
</ol>
</p>
</p>
