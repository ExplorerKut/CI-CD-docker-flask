# CI-CD-docker-flask

A CI/CD pipeline which deploys a docker image to ECR, lints the python code and pushes the updated image.

## To build the docker image use the below command

### => docker build . --tag "name-of-image"

## Define Your custom message using the CUSTOM_MESSAGE environment variable in the my-env.txt file

### CUSTOM_MESSAGE="Any message you like"

## To run and start the docker container pass the environment variable file to the container

### => docker run -p 5000:5000 --env-file my-env.txt "name-of-image"

## The environment variable is by default set in dockerfile itself, the message can be changed by changing the docker file you can omit the above steps as the workflow will automatically build the new image and push it to the ecr repository, and deploy it on ECS using fargate

### CI/CD using GitHub Actions

<p>
For the purpose of linting the codebase a GitHub action named super-linter has been used for linting the entire codebases, the linter can handle
languages like python, javascript, yaml and many more.

### main.yaml

```yaml
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
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: flask-docker-web-app
          IMAGE_TAG: ${{ github.sha }}
        run:  |
          docker build -t  ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .
          docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
          echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with: 
          task-definition: ecs-task-definition.json
          container-name: flask-web-app
          image: ${{ steps.build-image.outputs.image }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with: 
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: flask-app-service
          cluster: flask-app
          wait-for-service-stability: false


```

A workflow containing different jobs has been created, the jobs are discussed below:

```yaml


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
```

<p>
    <ol>
        <li>Lint Code base</li>
            <ol>
                <li>Checkout the repository for workflow access</li>
                <li>Uses the super-linter action from the GitHub marketplace and scans the code for any linting errors</li>
            </ol>
    </ol>
</p>

```yaml

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
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: flask-docker-web-app
          IMAGE_TAG: ${{ github.sha }}
        run:  |
          docker build -t  ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG} .
          docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}
          echo "::set-output name=image::$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"

      - name: Fill in the new image ID in the Amazon ECS task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with: 
          task-definition: ecs-task-definition.json
          container-name: flask-web-app
          image: ${{ steps.build-image.outputs.image }}

      - name: Deploy Amazon ECS task definition
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with: 
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: flask-app-service
          cluster: flask-app
          wait-for-service-stability: false
```

## The steps for the above job are discuseed below step by step

<p>
        <ol>
                <li>This job requires the code to be linted first</li>
                <li>Configure aws credentials by providing access key, secret key, aws region as secrets in GitHub actions</li>
                <li>Build the image and publish to private ECR repository (Note a repository needs to be initialised in the aws console first the repository name needs to be provided for the same)</li>
                <li>Before deploying the new image to ECS, Configure ECS by creating a Cluster in the console, create a task definition by providing the image url, and create a service for the same </li>
                <li>Store the task definition as json in the GitHub repository</li>
                <li>Provide the task-definition url in the task-definiton variable</li>
                <li>Provide the container-name </li>
                <li>Deploy to amazon ecs by providing service name and cluster name.
        </ol>
</p>
