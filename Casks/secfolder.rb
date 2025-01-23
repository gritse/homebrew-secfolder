cask 'secfolder' do
  version "0.1.4"
  sha256 :no_check

  url "https://secfolder.blob.core.windows.net/brew/SecFolder-#{version}.zip"
  name 'SecFolder'
  homepage 'https://secfolder.net'

  depends_on cask: "santa"
  depends_on macos: ">= :sonoma"
  
  app 'SecFolder.app'

  preflight do
    system_command 'mkdir',
                   args: ['-p', '/Library/Preferences/SecFolder'],
                   sudo: true
    system_command 'mkdir',
                   args: ['-p', File.expand_path('~/SecretDocuments')],
                   sudo: false
    system_command 'cp',
                   args: [
                     staged_path.join('readme.txt'),
                     File.expand_path('~/SecretDocuments/readme.txt')
                   ],
                   sudo: false
    system_command "xattr",
                   args: [
                     "-d", "com.apple.quarantine", staged_path.join('SecFolder.app')
                   ],
                   sudo: true
      system_command "codesign",
                   args: [
                     "--deep", "-f", "-s", "-", "--verbose=4", staged_path.join('SecFolder.app')
                   ],
                   sudo: true
  end

  postflight do
    system_command 'cp',
                   args: [
                     staged_path.join('com.warsaw.SecFolder.Helper.plist'),
                     '/Library/LaunchDaemons/com.warsaw.SecFolder.Helper.plist'
                   ],
                   sudo: true
    system_command "launchctl",
                   args: [
                     "load", "-w", "/Library/LaunchDaemons/com.warsaw.SecFolder.Helper.plist"
                   ],
                   sudo: true
    system_command 'open',
                   args: [staged_path.join('com.google.santa.SecFolder.mobileconfig')],
                   sudo: false
  end
  
  caveats do
  	license "https://secfolder.net/terms.html"
  end
  
  uninstall delete:		['/Applications/SecFolder.app'],
            quit:    	['com.warsaw.SecFolder', 'com.warsaw.SecFolder.Helper'],
            launchctl: 	'com.warsaw.SecFolder.Helper'
            

  zap trash: [
    '~/Library/Application Support/SecFolder',
    '~/Library/Application Support/com.warsaw.SecFolder',
    '~/Library/Caches/com.warsaw.SecFolder',
    '~/Library/Preferences/com.warsaw.SecFolder.plist',
    '~/Library/Saved Application State/com.warsaw.SecFolder.savedState',
    '/Users/Shared/SecFolder',
    '/Library/Preferences/SecFolder'
  ]
end