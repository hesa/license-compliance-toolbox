from myort:latest

ENV LICENSE_DETECTOR_VERSION=v4.2.0

ADD "https://github.com/go-enry/go-license-detector/releases/download/${LICENSE_DETECTOR_VERSION}/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz" /opt/license-detector-${LICENSE_DETECTOR_VERSION}-linux-amd64.tar.gz
RUN set -x \

 `# install ninka` \
 && apt-get update \
 && apt-get install -y --no-install-recommends ninka ninka-backend-excel ninka-backend-sqlite \
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
 && chmod a+x license-detector \
 && cd - \

 `# fetch armijnhemel/compliance-scripts` \
 && git clone --recurse-submodules https://github.com/armijnhemel/compliance-scripts.git /opt/armijnhemel-compliance-scripts \

 `# fetch vinland-technology/compliance-utils` \
 && git clone https://github.com/vinland-technology/compliance-utils.git /opt/vinland-technology-compliance-utils \

 `# fetch vinland-technology/scancode-manifestor` \
 && git clone https://github.com/vinland-technology/scancode-manifestor.git /opt/vinland-technology-scancode-manifestor
