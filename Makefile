
.PHONY: all push

all: .
	docker build -t iameli/drumstick-eli .

push: .
	docker push iameli/drumstick-eli
