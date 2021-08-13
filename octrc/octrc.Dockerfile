FROM ort:latest

RUN set -x \
    && rm -rf /usr/local/scancode-toolkit-$SCANCODE_VERSION \
    && rm /usr/local/bin/scancode
ARG SCANCODE_VERSION=21.8.4
ARG LICENSE_DETECTOR_VERSION=v4.2.0
ARG SCANOSS_VERSION=1.3.4

ENV JAVA_OPTS "-Xms2048M -Xmx16g -XX:MaxPermSize=4096m -XX:MaxMetaspaceSize=4g"
RUN set -x \
 && ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""

RUN set -x \
    && curl -ksSL https://github.com/nexB/scancode-toolkit/archive/v$SCANCODE_VERSION.tar.gz | \
        tar -zxC /opt \
    && cd /opt/scancode-toolkit-$SCANCODE_VERSION \
    # Trigger ScanCode configuration for Python 3 and reindex licenses initially.
    && PYTHON_EXE=/usr/bin/python3 /opt/scancode-toolkit-$SCANCODE_VERSION/scancode --reindex-licenses \
    && chmod -R o=u /opt/scancode-toolkit-$SCANCODE_VERSION \
    && ln -snf /opt/scancode-toolkit-$SCANCODE_VERSION/scancode /usr/local/bin/scancode \
    && ln -snf /opt/scancode-toolkit-$SCANCODE_VERSION/extractcode /usr/local/bin/extractcode

ADD "https://github.com/go-enry/go-license-detector/releases/download/${LICENSE_DETECTOR_VERSION}/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz" /opt/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt set -x \

    && ln -s /opt/ort/bin/ort /usr/local/bin/ort \
    && ln -s /opt/ort/bin/orth /usr/local/bin/orth \

    && apt-get update \
    && apt-get install -y --no-install-recommends \
        # install ninka
        ninka ninka-backend-excel ninka-backend-sqlite \
        # install tools
        exiftool cloc jq file libncurses5-dev libncursesw5-dev \
        # for scanoss
        libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \

    # install rake
    && gem install rake \

    # install reuse
    && pip3 install reuse \

    # install swh.scanner
    # && pip3 install swh.scanner` \

    # install scanoss scanner
    && curl -L "https://github.com/scanoss/scanner.c/releases/download/v${SCANOSS_VERSION}/scanoss-scanner-${SCANOSS_VERSION}-amd64.deb" --output "/tmp/scanoss-scanner-${SCANOSS_VERSION}-amd64.deb" \
    && dpkg -i "/tmp/scanoss-scanner-${SCANOSS_VERSION}-amd64.deb" \
    && rm "/tmp/scanoss-scanner-${SCANOSS_VERSION}-amd64.deb" \

    # install license detector
    && cd /opt \
    && tar zxvf license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz \
    && rm license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz \
    && chmod a+x license-detector

ADD armijnhemel-compliance-scripts /opt/armijnhemel-compliance-scripts
ADD vinland-technology-compliance-utils /opt/vinland-technology-compliance-utils
ADD vinland-technology-scancode-manifestor /opt/vinland-technology-scancode-manifestor
ADD nexB-scancode-toolkit/scancode.scan.sh /usr/local/bin
ADD cmff.sh /usr/local/bin
ADD findDefinitionFiles.sh /usr/local/bin

################################################################################
################################################################################
################################################################################

RUN set -x \
    && mkdir -p /inputs /outputs
WORKDIR /

ADD octrc/octrc.entrypoint.sh /usr/local/bin
ENTRYPOINT /usr/local/bin/octrc.entrypoint.sh

ADD octrc/octrc.Rakefile /
