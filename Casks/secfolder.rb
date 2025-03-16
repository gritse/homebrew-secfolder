cask 'secfolder' do
  version "0.1.6"
  sha256 :no_check

  url "https://secfolder.blob.core.windows.net/brew/SecFolder-#{version}.zip"
  name 'SecFolder'
  homepage 'https://secfolder.net'

  depends_on cask: "santa@2024.9"
  depends_on macos: ">= :ventura"
  
  app 'SecFolder.app'

  preflight do
    begin
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
    rescue => e
      opoo "An error occurred while copying readme.txt, but it's safe to ignore"
    end

    begin
      system_command "xattr",
                    args: [
                      "-d", "com.apple.quarantine", staged_path.join('SecFolder.app')
                    ],
                    sudo: true
    rescue => e
      opoo "An error occurred while removing com.apple.quarantine xattr, but it's safe to ignore, I guess..."
    end

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
  
  uninstall delete:		[],
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