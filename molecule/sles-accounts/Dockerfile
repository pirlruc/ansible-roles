FROM registry.suse.com/bci/bci-base:16.0@sha256:60c29bd0b778062d1a96ed3edca81361afc11ee962a8b12d578b90204c587f8b
# DL3037: python3, shadow, and sudo come from the BCI image repository.
# SUSE does not publish a lockfile for that repository that this role repo can pin.
# hadolint ignore=DL3037
RUN zypper --non-interactive refresh \
    && zypper --non-interactive install python3 shadow sudo \
    && zypper --non-interactive clean
