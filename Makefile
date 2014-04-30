BASE_PACKAGE_NAME:=puppet-omnibus
VERSION:=3.0.2
EXTRA:=yelp1

DOCKER_RUN:=docker run -v  $(CURDIR):/package:rw

LUCID_OUTPUT_PACKAGE_NAME   :=dist/lucid/$(BASE_PACKAGE_NAME)_$(VERSION)-$(EXTRA)_amd64.deb
PRECISE_OUTPUT_PACKAGE_NAME :=dist/precise/$(BASE_PACKAGE_NAME)_$(VERSION)-$(EXTRA)_amd64.deb
CENTOS5_OUTPUT_PACKAGE_NAME :=dist/centos5/$(BASE_PACKAGE_NAME)_$(VERSION)-$(EXTRA).x86_64.rpm
CENTOS6_OUTPUT_PACKAGE_NAME :=dist/centos6/$(BASE_PACKAGE_NAME)_$(VERSION)-$(EXTRA).x86_64.rpm

itest_lucid:   package_lucid
	$(DOCKER_RUN) /itest/ubuntu.sh $(LUCID_OUTPUT_PACKAGE_NAME)
itest_precise: package_precise
	$(DOCKER_RUN) /itest/ubuntu.sh $(PRECISE_OUTPUT_PACKAGE_NAME)
itest_centos5: package_centos5
	/bin/true # TODO: We need centos docker images and /itest/centos.sh
itest_centos6: package_centos6
	/bin/true # TODO: We need centos docker images and /itest/centos.sh

package_lucid:   test_lucid   $(LUCID_OUTPUT_PACKAGE_NAME)
package_precise: test_precise $(PRECISE_OUTPUT_PACKAGE_NAME)
package_centos5: test_centos5 $(CENTOS5_OUTPUT_PACKAGE_NAME)
package_centos6: test_centos6 $(CENTOS6_OUTPUT_PACKAGE_NAME)

$(LUCID_OUTPUT_PACKAGE_NAME):
	$(DOCKER_RUN) package_puppet_lucid /package/JENKINS_BUILD.sh
$(PRECISE_OUTPUT_PACKAGE_NAME):
	$(DOCKER_RUN) package_puppet_lucid /package/JENKINS_BUILD.sh
$(CENTOS5_OUTPUT_PACKAGE_NAME):
	$(DOCKER_RUN) package_puppet_lucid /package/JENKINS_BUILD.sh
$(CENTOS6_OUTPUT_PACKAGE_NAME):
	$(DOCKER_RUN) package_puppet_lucid /package/JENKINS_BUILD.sh

test_lucid:   .lucid_docker_is_created
	/bin/true
test_precise: .precise_docker_is_created
	/bin/true
test_centos5: .centos5_docker_is_created
	/bin/true
test_centos6: .centos6_docker_is_created
	/bin/true

.lucid_docker_is_created:
	# We lock the building of the container, because multiple simultaneous docker builds
	# don't make anything faster.
	cd dockerfiles/ubuntu_lucid && flock /tmp/lucid_docker_build.lock docker build -t "package_puppet_ubuntu_lucid" .
	touch .lucid_docker_is_created
.precise_docker_is_created:
	cd dockerfiles/ubuntu_precise && flock /tmp/precise_docker_build.lock docker build -t "package_puppet_ubuntu_precise" .
	touch .precise_docker_is_created
.centos5_docker_is_created:
	cd dockerfiles/centos_5 && flock /tmp/centos5_docker_build.lock docker build -t "package_puppet_centos_5" .
	touch .centos5_docker_is_created	   
.centos6_docker_is_created:
	cd dockerfiles/centos_5 && flock /tmp/centos6_docker_build.lock docker build -t "package_puppet_centos_6" .
	touch .centos5_docker_is_created

clean:
	rm -rf dist/
	rm .*docker_is_created

