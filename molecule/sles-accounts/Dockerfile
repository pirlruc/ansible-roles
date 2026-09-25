FROM registry.suse.com/bci/bci-base:16.0
RUN zypper --non-interactive refresh \
    && zypper --non-interactive install python3 shadow sudo \
    && zypper --non-interactive clean
