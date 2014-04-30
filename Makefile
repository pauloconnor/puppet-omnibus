BASE_PACKAGE_NAME:=puppet-omnibus
VERSION:=3.0.2
#BUILD_NUMBER:=debug0
#OS:=ubuntu_lucid

DOCKER_RUN:=docker run -u jenkins -e BUILD_NUMBER=$(BUILD_NUMBER)

OUTPUT_PACKAGE_NAME   :=pkg/$(BASE_PACKAGE_NAME)_$(VERSION)+yelp$(BUILD_NUMBER)_amd64.deb

itest:   package
	$(DOCKER_RUN) -v $(CURDIR)/pkg:/package_dest:ro package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/itest/$(OS).sh /package_dest/$(OUTPUT_PACKAGE_NAME)

package:   test   $(OUTPUT_PACKAGE_NAME)

$(OUTPUT_PACKAGE_NAME):
	if [ ! -d pkg/ ]; then mkdir pkg; fi
	chmod 777 pkg
	$(DOCKER_RUN) -v $(CURDIR):/package_source:ro -v $(CURDIR)/pkg:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh

test:   .docker_is_created
	/bin/true

.docker_is_created:
	# We lock the building of the container, because multiple simultaneous docker builds
	# don't make anything faster.
	docker images | grep "package_$(BASE_PACKAGE_NAME)_$(OS)" >/dev/null 2>&1 ; if [ "$$?" -eq "0" ];then /bin/true; else cd dockerfiles/$(OS) && flock /tmp/container_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .; fi
	touch .docker_is_created

clean:
	rm -rf pkg/ cache/
	rm -f .docker_is_created

