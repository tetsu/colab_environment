# Colab Environment

## Notes

1. NVIDIA Container Toolkit:

    Make sure you have nvidia-container-toolkit installed on the host system.

1. Docker Compose GPU Support:

    - If you use Docker Compose v2 or newer, you can specify GPU usage via the deploy.resources.reservations.devices as shown above.
    - For older Docker Compose versions, you can set runtime: nvidia or device_requests. See the official docs for details.

1. Mount a directory:
    We do `- .:/workspace` to mount the current directory into the container at /workspace. Adjust as needed.

## Build and Run

1. Build the container:

    ```bash
    docker compose build
    ```

1. Start the container:

    ```bash
    docker compose up -d
    ```

1. Attach to the container:

    ```bash
    docker-compose exec pytorch bash
    ```

    Now you’re inside the container shell with (myenv) automatically activated (if using the entrypoint script).

    - You can verify GPU access:

        ```
        python -c "import torch; print(torch.cuda.is_available())"
        ```

1. Stop the container (if you ran it in the background):

    ```bash
    docker-compose down
    ```

## Extra Tips

1. Multiple Containers:

    If you have multiple containers in your docker-compose.yml, each can reference the same Dockerfile or a different base image as needed.

2. Enabling Jupyter:

    - Expose ports in your docker-compose.yml:

        ```yaml
        ports:
        - "8888:8888"
        ```

    - Then inside your container, you can run:

        ```bash
        jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
        ```

    - Access the notebook via [http://localhost:8888](http://localhost:8888) on the host machine.

1. Data Volumes:

    - To work with large datasets, mount additional volumes or point to external storage.

1. Production vs. Development:

    - For dev, using a -devel base image is convenient (since you can compile things). For production, sometimes people prefer a -runtime image for smaller size.

1. Building PyTorch from Source for CUDA 12.4

    - As noted in the Dockerfile comments, you’d typically clone PyTorch and run python setup.py install. This can make your build quite large and take considerable time. If you must do this regularly, consider setting up a multi-stage build to keep the final image lean.