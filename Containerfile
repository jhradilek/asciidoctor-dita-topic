FROM fedora-minimal:latest

RUN microdnf install -y python3-pip rubygems inotify-tools entr gum elinks less tput
RUN gem install asciidoctor-{dita-topic,dita-map,list-content}
RUN pip install --root-user-action=ignore dita-{convert,cleanup}
COPY scripts/convert.sh /usr/local/bin/convert
COPY scripts/dita-help.sh /usr/local/bin/dita-help

VOLUME /docs
WORKDIR /docs
CMD ["/usr/local/bin/convert"]
