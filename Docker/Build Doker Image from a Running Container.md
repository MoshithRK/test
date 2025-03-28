# Creating a Docker Image from a Running Container

This guide provides step-by-step instructions to create a Docker image from a running container.

## Prerequisites
- Docker installed on your system.
- A running Docker container.

## Step 1: List Running Containers
To identify the container you want to save as an image, run:

```bash
sudo docker ps
```

Take note of the **CONTAINER ID** or **NAME** of the running container.

## Step 2: Commit the Container to an Image
Use the `docker commit` command to create an image from the running container.

```bash
sudo docker commit <CONTAINER_ID> <IMAGE_NAME>:<TAG>
```

For example:
```bash
sudo docker commit nginx-test my-nginx-container:v1
```

## Step 3: Verify the New Image
Check if the new image has been created:

```bash
sudo docker images
```

You should see the newly created image in the list.

## Step 4: Run a Container from the New Image
To test the new image, create a container from it:

```bash
sudo docker run -d -p 8081:80 --name new-nginx my-nginx-container:v1
```

Now, visit `http://localhost:8081` in your browser to verify it is running correctly.

## Step 5: Save the Image as a Tar File (Optional)
If you want to export the image for sharing or backup:

```bash
sudo docker save -o my-nginx-container.tar my-nginx-container:v1
```

To load the image on another system:

```bash
sudo docker load -i my-nginx-container.tar
```

## Conclusion
By following these steps, you can successfully create an image from a running container, ensuring your customized environment is preserved for future use.

