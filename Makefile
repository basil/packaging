# refers to the definition of a release target
BRAND ?= ./branding/test.mk
include ${BRAND}

# refers to the definition of the release process execution environment
BUILDENV ?=./env/test.mk
include ${BUILDENV}

# refers to whereabouts of code-signing keys
# CREDENTIAL ?=./credentials/test.mk

include ${CREDENTIAL}

include ./setup.mk

PACKAGE_BUILDER_VERSION:=0.1

#######################################################

clean:
	rm -rf ${TARGET}

setup:
	bash -ex -c 'for f in */setup.sh; do $$f; done'

package: war deb rpm suse osx

publish: war.publish deb.publish rpm.publish suse.publish osx.publish

war: ${WAR}
war.publish: ${WAR}
	./war/publish/publish.sh

osx: ${OSX}
${OSX}: ${WAR} ${CLI}  $(shell find osx -type f | sed -e 's/ /\\ /g')
	./osx/build-on-jenkins.sh
osx.publish: ${OSX}
	./osx/publish.sh



deb: ${DEB}
${DEB}: ${WAR} $(shell find deb/build -type f)
	./deb/build/build.sh
deb.publish: ${DEB} $(shell find deb/publish -type f)
	./deb/publish/publish.sh



rpm: ${RPM}
${RPM}: ${WAR}  $(shell find rpm/build -type f)
	./rpm/build/build.sh
rpm.publish: ${RPM} $(shell find rpm/publish -type f)
	./rpm/publish/publish.sh

suse: ${SUSE}
${SUSE}: ${WAR}  $(shell find suse/build -type f)
	./suse/build/build.sh
suse.publish: ${SUSE} $(shell find suse/publish -type f)
	./suse/publish/publish.sh

msi.publish:
	./msi/publish/publish.sh

${CLI}:
	@mkdir ${TARGET} || true
	wget -O $@.tmp ${JENKINS_URL}jnlpJars/jenkins-cli.jar
	mv $@.tmp $@
