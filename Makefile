build:
	docker build \
		-t docker-rocm \
		-f Dockerfile .

bash:
	docker run -it --rm \
		-w /app \
		-v .:/app \
		-v ./huggingface:/root/.cache/huggingface \
		--device=/dev/kfd \
		--device=/dev/dri \
		docker-rocm:latest bash
