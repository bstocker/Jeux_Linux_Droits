FROM mcr.microsoft.com/devcontainers/base:ubuntu

# L'image n'autorise sudo sans mot de passe que pour devenir root.
# Le jeu a aussi besoin de « sudo -u bob ... » (agir en tant qu'alice, bob ou eve).
RUN echo 'vscode ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/jeu-droits \
    && chmod 440 /etc/sudoers.d/jeu-droits
