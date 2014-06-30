# Targets to run itests on each distro using the special stock test containers
itest_hardy:
	rake itest_hardy
itest_lucid:
	rake itest_lucid
itest_precise:
	rake itest_precise
itest_trusty:
	rake itest_trusty
itest_centos5:
	rake itest_centos5
itest_centos6:
	rake itest_centos6

clean:
	rm -rf dist/ cache/
	rm -f .*docker_is_created
