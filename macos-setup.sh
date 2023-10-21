sudo -v

# Allow quitting via ⌘Q
defaults write com.apple.finder QuitMenuItem -bool true

# Disable warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show all files and their extensions
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar, and layout as multi-column
defaults write com.apple.finder ShowPathbar -bool true

# Search in current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string SCcf

# Show directories first
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# New window use the $HOME path
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# --- Unpin all apps
# defaults write com.apple.dock persistent-apps -array ""
#

# Set icon size and dock orientation
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock orientation -string left

# Enable full keyboard access for all controls
defaults write -g AppleKeyboardUIMode -int 3

# Enable press-and-hold repeating
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1

# Disable "Natural" scrolling
defaults write -g com.apple.swipescrolldirection -bool false

defaults write -g NSAutomaticCapitalizationEnabled -bool false

# Increase window resize speed for Cocoa applications
defaults write -g NSWindowResizeTime -float 0.001

# Enable 3-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# For better privacy
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Disable auto open downloads
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Enable Develop Menu, Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtras -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# Avoid creating .DS_Store files on USB or network volumes

defaults write com.apple.desktopservices dsdontwriteusbstores -bool true
defaults write com.apple.desktopservices dsdontwritenetworkstores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Disable personalized advertising
defaults com.apple.AdLib forceLimitAdTracking -bool true
defaults com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults com.apple.AdLib allowIdentifierForAdvertising -bool false

sudo spctl --master-disable

# brew install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"

brew install rcm

cp -r ~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/Config/ssh ~/.ssh

cd
git clone git@github.com:Innei/dotfiles.git .dotfiles
rcup -t base
rcup -t fzf-mac
mkdir -p .config
git clone git@github.com:Innei/nvim-config-lua.git nvim

mv .Brewfile Brewfile
brew bundle install


sudo reboot