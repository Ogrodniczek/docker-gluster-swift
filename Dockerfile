FROM centos:7

RUN yum install -y epel-release

RUN yum install -y yasm supervisor memcached gcc python-devel libffi-devel make autoconf automake libtool zlib-devel redhat-lsb python-pip liberasurecode-devel python-scandir python-prettytable git centos-release-openstack-pike

RUN yum install -y liberasurecode-devel

RUN pip install --upgrade pip cryptography requests pyparsing

RUN git clone https://github.com/openstack/liberasurecode.git && \
    cd liberasurecode/ && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd - && \
    rm -rf liberasurecode/ 

RUN git clone https://github.com/openstack/pyeclib.git && \
    cd pyeclib/ && \
    pip install -U bindep -r test-requirements.txt && \
    pip install -r test-requirements.txt && \
    bindep -f bindep.txt && \
    python setup.py install && \
    cd - && \
    rm -rf pyeclib


RUN git clone https://github.com/gluster/gluster-swift; cd gluster-swift && \
    python setup.py install && \
    mkdir -p /etc/swift/ && \ 
    cp etc/* /etc/swift/ && \
    cd /etc/swift/ && \
    for tmpl in *.conf-gluster ; do cp ${tmpl} ${tmpl%.*}.conf; done  && \
    cd - && \
    cd .. && \
    rm -rf gluster-swift


RUN git clone https://github.com/openstack/swift; cd swift && \
    git checkout -b release-2.10.1 tags/2.10.1  && \
    pip install -r test-requirements.txt && \
    pip install -r ./requirements.txt && \
    python setup.py install && \
    cd - && \
    rm -rf swift 


VOLUME /mnt/gluster-object
RUN mkdir -p /etc/supervisor /var/log/supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY swift-start.sh /usr/local/bin/swift-start.sh
RUN chmod +x /usr/local/bin/swift-start.sh
COPY supervisor_suicide.py /usr/local/bin/supervisor_suicide.py
RUN chmod +x /usr/local/bin/supervisor_suicide.py


CMD /usr/local/bin/swift-start.sh


