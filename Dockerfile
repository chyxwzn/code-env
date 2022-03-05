# Start from the code-server Debian base image
FROM codercom/code-server:latest as code-server
COPY entrypoint.sh /usr/bin/container-entrypoint.sh
# Fix permissions for code-server
RUN sudo chmod +x /usr/bin/container-entrypoint.sh \
&& code-server --install-extension CoenraadS.bracket-pair-colorizer-2 \
&& code-server --install-extension eamodio.gitlens \
&& code-server --install-extension jebbs.plantuml \
&& code-server --install-extension ms-azuretools.vscode-docker \
&& code-server --install-extension ms-python.python \
&& code-server --install-extension ms-toolsai.jupyter \
&& code-server --install-extension vscode-icons-team.vscode-icons \
&& code-server --install-extension zhuangtongfa.material-theme \
&& code-server --install-extension yzhang.markdown-all-in-one

FROM code-server as sshd-debian
RUN sudo sed -i 's/deb.debian.org/mirrors.cloud.tencent.com/g' /etc/apt/sources.list \
&& sudo sed -i 's/security.debian.org/mirrors.cloud.tencent.com/g' /etc/apt/sources.list

RUN sudo apt-get update && sudo apt-get -y install git neovim python3-pip \
&& pip3 install pylint flake8 autopep8 pydocstyle pycodestyle powerline-shell

# https://github.com/microsoft/vscode-dev-containers
COPY common-debian.sh sshd-debian.sh /tmp/library-scripts/
RUN sudo bash /tmp/library-scripts/common-debian.sh \
&& sudo bash /tmp/library-scripts/sshd-debian.sh \
&& mkdir /home/coder/.ssh && chmod 700 /home/coder/.ssh \
&& touch /home/coder/.ssh/authorized_keys && chmod 644 /home/coder/.ssh/authorized_keys

FROM sshd-debian as code-env
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
&& ~/.fzf/install --all \
&& git clone --depth 1 https://github.com/clvv/fasd.git ~/.fasd.git \
&& cd .fasd.git && sudo make install && cd ~

RUN git clone --depth 1 https://github.com/chyxwzn/configFiles.git ~/configFiles \
&& cp ~/configFiles/bashrc ~/.bashrc \
&& cp ~/configFiles/zshrc ~/.zshrc \
&& cp ~/configFiles/commrc ~/.commrc \
&& cp ~/configFiles/gitconfig ~/.gitconfig \
&& mkdir -p ~/.local/share/code-server/User \
&& cp ~/configFiles/settings.json ~/.local/share/code-server/User/settings.json

# Use our custom entrypoint script first
ENTRYPOINT ["/usr/bin/container-entrypoint.sh"]