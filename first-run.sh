#! /bin/bash
set +x

SKIP_OMZSH=false
SKIP_VIM=false

install_oh_my_zsh() {
  if $SKIP_OMZSH ; then
    return 0
  else
    echo "Installing Oh My ZSH..."
  fi

  umask g-w,o-w
  git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
}

configure_vim() {
  if $SKIP_VIM ; then
    return 0
  else
    echo "Configuring Vim..."
  fi

  mkdir -p .vim/bundle
  git clone https://github.com/VundleVim/Vundle.vim.git \
    .vim/bundle/Vundle.vim
  vim -E -u NONE -S .vim/plugins.vimrc +PluginInstall +qa

  pushd .vim/bundle/YouCompleteMe
  ./install.py --clang-completer --go-completer --java-completer
  popd
}

echo "Running $0 ..."

configure_vim
install_oh_my_zsh

zsh
