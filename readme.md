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
    docker-compose build
    ```

1. Start the container:

    ```bash
    docker-compose up -d
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