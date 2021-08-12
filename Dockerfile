from myort:latest

ENV LICENSE_DETECTOR_VERSION=v4.2.0

ADD "https://github.com/go-enry/go-license-detector/releases/download/${LICENSE_DETECTOR_VERSION}/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz" /opt/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz
ADD armijnhemel-compliance-scripts /opt
ADD vinland-technology-compliance-utils /opt
Add vinland-technology-scancode-manifestor /opt
RUN set -x \

 && apt-get update \
 && apt-get install -y --no-install-recommends \
    `# install ninka` \
    ninka ninka-backend-excel ninka-backend-sqlite \
    `# install exiftool` \
    exiftool \
    `# install cloc` \
    cloc \
    `# install jq` \
    jq \
 && rm -rf /var/lib/apt/lists/* \

 `# install reuse` \
 && pip3 install reuse \

 `# install swh.scanner` \
 `# && pip3 install swh.scanner` \

 `# install license detector` \
 && cd /opt \
 && tar zxvf license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz \
 && rm license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz \
 && chmod a+x license-detector
