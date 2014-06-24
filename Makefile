BASE_PACKAGE_NAME:=puppet-omnibus
VERSION:=3.6.2
#BUILD_NUMBER:=2
BUILD_NUMBER:=$(upstream_build_number)

CURDIR:=$(shell /bin/pwd)

all: itest_hardy itest_lucid itest_precise itest_trusty itest_centos5 itest_centos6
build_all: package_hardy package_lucid package_precise package_trusty package_centos5 package_centos6

HARDY_OUTPUT_PACKAGE_NAME   :=dist/hardy/$(BASE_PACKAGE_NAME)_$(VERSION)+yelp-$(BUILD_NUMBER)_amd64.deb
LUCID_OUTPUT_PACKAGE_NAME   :=dist/lucid/$(BASE_PACKAGE_NAME)_$(VERSION)+yelp-$(BUILD_NUMBER)_amd64.deb
PRECISE_OUTPUT_PACKAGE_NAME :=dist/precise/$(BASE_PACKAGE_NAME)_$(VERSION)+yelp-$(BUILD_NUMBER)_amd64.deb
TRUSTY_OUTPUT_PACKAGE_NAME  :=dist/trusty/$(BASE_PACKAGE_NAME)_$(VERSION)+yelp-$(BUILD_NUMBER)_amd64.deb
CENTOS5_OUTPUT_PACKAGE_NAME :=dist/centos5/$(BASE_PACKAGE_NAME)-$(VERSION).yelp_$(BUILD_NUMBER)-1.x86_64.rpm
CENTOS6_OUTPUT_PACKAGE_NAME :=dist/centos6/$(BASE_PACKAGE_NAME)-$(VERSION).yelp_$(BUILD_NUMBER)-1.x86_64.rpm

DOCKER_RUN:=unbuffer docker run -t -i  -e BUILD_NUMBER=$(BUILD_NUMBER) -v $(CURDIR):/package_source:ro

DOCKER_HARDY_TEST_RUN:=docker run -v   $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/hardy_yelp
DOCKER_LUCID_TEST_RUN:=docker run -v   $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/lucid_yelp
DOCKER_PRECISE_TEST_RUN:=docker run -v $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/precise_yelp
DOCKER_TRUSTY_TEST_RUN:=docker run -v  $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/trusty_yelp
DOCKER_CENTOS5_TEST_RUN:=docker run -v $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/centos5_yelp
DOCKER_CENTOS6_TEST_RUN:=docker run -v $(CURDIR)/itest:/itest:ro -v $(CURDIR)/dist:/dist:ro docker-dev.yelpcorp.com/centos6_yelp

all: itest_hardy itest_lucid itest_precise itest_trusty itest_centos5 itest_centos6

# Targets to run itests on each distro using the special stock test containers
itest_hardy:   package_hardy
	$(DOCKER_HARDY_TEST_RUN) /itest/hardy.sh /$(HARDY_OUTPUT_PACKAGE_NAME)
itest_lucid:   package_lucid
	$(DOCKER_LUCID_TEST_RUN) /itest/lucid.sh /$(LUCID_OUTPUT_PACKAGE_NAME)
itest_precise: package_precise
	$(DOCKER_PRECISE_TEST_RUN) /itest/precise.sh /$(PRECISE_OUTPUT_PACKAGE_NAME)
itest_trusty:  package_trusty
	$(DOCKER_TRUSTY_TEST_RUN) /itest/trusty.sh /$(TRUSTY_OUTPUT_PACKAGE_NAME)
itest_centos5: package_centos5
	$(DOCKER_CENTOS5_TEST_RUN) /itest/centos5.sh /$(CENTOS5_OUTPUT_PACKAGE_NAME)
itest_centos6: package_centos6
	$(DOCKER_CENTOS6_TEST_RUN) /itest/centos6.sh /$(CENTOS6_OUTPUT_PACKAGE_NAME)

# Named targets that depend on the docker AND the package
package_hardy:   .hardy_docker_is_created $(HARDY_OUTPUT_PACKAGE_NAME)
package_lucid:   .lucid_docker_is_created $(LUCID_OUTPUT_PACKAGE_NAME)
package_precise: .precise_docker_is_created $(PRECISE_OUTPUT_PACKAGE_NAME)
package_trusty:  .trusty_docker_is_created $(TRUSTY_OUTPUT_PACKAGE_NAME)
package_centos5: .centos5_docker_is_created $(CENTOS5_OUTPUT_PACKAGE_NAME)
package_centos6: .centos6_docker_is_created $(CENTOS6_OUTPUT_PACKAGE_NAME)

# Targets to build the PACKAGE itself
$(HARDY_OUTPUT_PACKAGE_NAME): OS=hardy
$(HARDY_OUTPUT_PACKAGE_NAME):
	[ -d dist/hardy ] || mkdir -p dist/hardy
	chmod 777 dist/hardy/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/hardy/:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /bin/bash /package_source/JENKINS_BUILD.sh
$(LUCID_OUTPUT_PACKAGE_NAME): OS=lucid
$(LUCID_OUTPUT_PACKAGE_NAME):
	[ -d dist/lucid ] || mkdir -p dist/lucid
	chmod 777 dist/lucid/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/lucid/:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh
$(PRECISE_OUTPUT_PACKAGE_NAME): OS=precise
$(PRECISE_OUTPUT_PACKAGE_NAME):
	[ -d dist/precise ] || mkdir -p dist/precise
	chmod 777 dist/precise/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/precise:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh
$(TRUSTY_OUTPUT_PACKAGE_NAME): OS=trusty
$(TRUSTY_OUTPUT_PACKAGE_NAME):
	[ -d dist/trusty ] || mkdir -p dist/trusty
	chmod 777 dist/trusty/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/trusty:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh
$(CENTOS5_OUTPUT_PACKAGE_NAME): OS=centos5
$(CENTOS5_OUTPUT_PACKAGE_NAME):
	[ -d dist/centos5 ] || mkdir -p dist/centos5
	chmod 777 dist/centos5/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/centos5:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh
$(CENTOS6_OUTPUT_PACKAGE_NAME): OS=centos6
$(CENTOS6_OUTPUT_PACKAGE_NAME):
	[ -d dist/centos6 ] || mkdir -p dist/centos6
	chmod 777 dist/centos6/
	$(DOCKER_RUN) -u jenkins -e HOME=/package -v $(CURDIR)/dist/centos6:/package_dest:rw package_$(BASE_PACKAGE_NAME)_$(OS) /package_source/JENKINS_BUILD.sh

# Targets to build the DOCKERS for building the package
.hardy_docker_is_created: OS=hardy
.hardy_docker_is_created:
	cd dockerfiles/hardy && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created
.lucid_docker_is_created: OS=lucid
.lucid_docker_is_created:
	cd dockerfiles/$(OS) && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created
.precise_docker_is_created: OS=precise
.precise_docker_is_created:
	cd dockerfiles/$(OS) && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created
.trusty_docker_is_created: OS=trusty
.trusty_docker_is_created:
	cd dockerfiles/$(OS) && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created
.centos5_docker_is_created: OS=centos5
.centos5_docker_is_created:
	cd dockerfiles/$(OS) && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created
.centos6_docker_is_created: OS=centos6
.centos6_docker_is_created:
	cd dockerfiles/$(OS) && flock /tmp/$(BASE_PACKAGE_NAME)_$(OS)_docker_build.lock docker build -t "package_$(BASE_PACKAGE_NAME)_$(OS)" .
	touch .$(OS)_docker_is_created


$(OUTPUT_PACKAGE_NAME):
	if [ ! -d pkg/ ]; then mkdir pkg; fi
	chmod 777 pkg

clean:
	rm -rf dist/ cache/
	rm -f .*docker_is_created

