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
  shopt -s globstar

  # ==> Load helpers.
  source "lib/utils.bash"

  # ==> Link dotfiles.
  headline "Linking dotfiles"
  for rc in rc/**/*
  do
    target="$HOME/.$(cut -f2- -d/ <<< "$rc")"
    mkdir -p "$(dirname "$target")"
    [[ -f "$rc" ]] && ln -sf "$PWD/$rc" "$target"
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
  brew bundle

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

  # Update the max file limits.
  echo kern.maxfiles=65536 | sudo tee -a /etc/sysctl.conf
  echo kern.maxfilesperproc=65536 | sudo tee -a /etc/sysctl.conf
  sudo sysctl -w kern.maxfiles=65536
  sudo sysctl -w kern.maxfilesperproc=65536

  # TODO: figure out how to automatically remap caps lock to esc.
  # https://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool/88096#88096

  # Enable subpixel antialiasing so that non-4K external displays don't
  # look atrocious.
  defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO

  headline "Installing macOS Terminal color schemes"
  plutil -replace "Window Settings.Solarized Light" -xml "$(<misc/termcolor/solarized-light.xml)" ~/Library/Preferences/com.apple.Terminal.plist
  plutil -replace "Window Settings.Solarized Dark" -xml "$(<misc/termcolor/solarized-dark.xml)" ~/Library/Preferences/com.apple.Terminal.plist
  defaults write com.apple.Terminal "Default Window Settings" -string "Solarized Dark"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Solarized Dark"

  # ==> Install pending macOS updates.
  headline "Updating macOS"
  sudo softwareupdate --install --all
}
