FROM registry.suse.com/bci/bci-base:16.0@sha256:60c29bd0b778062d1a96ed3edca81361afc11ee962a8b12d578b90204c587f8b
# Versions from the SLE-BCI 16.0 x86_64 product repository for this base digest.
RUN zypper --non-interactive refresh \
    && zypper --non-interactive install \
        python3=3.13.14-160000.1.1 \
        shadow=4.17.2-160000.2.2 \
        sudo=1.9.17p1-160000.3.1 \
    && zypper --non-interactive clean
