# headline [MESSAGE...]
#
# Print MESSAGE as a nicely-formatted headline. Messages are printed in
# bold and preceded by an arrow, "==> ".
headline() {
  color "==> {bold}$@{clear}"
}

_dependencies_loaded=()
depend() {
  for dep in "${_dependencies_loaded[@]}"
  do
    if [[ $dep = "$1" ]]
    then
      return
    fi
  done
  _dependencies_loaded+=("$1")
  source "$1"
}

dotdotdot_install() {
  # ==> Load helpers.
  source "$DOTDOTDOT_ROOT/lib/utils.bash"

  # ==> Link dotfiles.
  headline "Linking dotfiles"
  for rc in "$DOTDOTDOT_ROOT"/rc/*
  do
    ln -sf "$rc" "$HOME/.$(basename "$rc")"
  done

  # ==> Maybe install Homebrew.
  if ! have_command brew
  then
    headline "Installing Homebrew"
    yes | /usr/bin/ruby -e "$(curl \
      --fail --silent --show-error --location \
      https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  # ==> Update Homebrew bundle.
  headline "Updating Homebrew bundle"
  brew bundle --file="$DOTDOTDOT_ROOT/Brewfile"

  # ==> Set macOS defaults.
  # These were lifted from @holman. Thanks, @holman!
  # See: https://github.com/holman/dotfiles/blob/06285813e51878e8d555aba62179d35318883257/macos/set-defaults.sh

  headline "Setting macOS defaults"

  # Disable press-and-hold for keys in favor of key repeat.
  defaults write -g ApplePressAndHoldEnabled -bool false

  # Use AirDrop over every interface.
  defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

  # Always open everything in Finder's list view.
  defaults write com.apple.Finder FXPreferredViewStyle Nlsv

  # Show the ~/Library folder.
  chflags nohidden ~/Library

  # Set up Safari for development.
  defaults write com.apple.Safari ShowFavoritesBar -bool false
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true


  # ==> Install pending macOS updates.
  headline "Updating macOS"
  sudo softwareupdate --install --all
}
