{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "alex";
  home.homeDirectory = "/home/alex";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 172;
  };

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    # Nix development tools
    nixd
    nixpkgs-fmt
    statix
    deadnix
    direnv  # Load environment variables based on directory

    neofetch
    nnn # terminal file manager

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg
    sublime-merge  # Git client by Sublime

    # fonts
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    
    # browsers
    google-chrome
    brave

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # Programming Languages & Tools
    go
    go-tools
    gopls
    delve
    
    rustc
    cargo
    rust-analyzer
    rustfmt
    
    nodejs_22
    nodePackages.typescript
    pnpm
    
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    gcc
    gnumake
    cmake
    ninja
    
    # Development Tools
    zed-editor  
    jetbrains-toolbox
    podman-desktop  # Docker Desktop alternative with Kubernetes support
    kubectl  # Kubernetes CLI
    k9s  # Kubernetes TUI dashboard
    kind  # Kubernetes in Docker - local clusters
    helm  # Kubernetes package manager
    vscode
    gh #GitHub CLI

    # Email
    thunderbird

    # AI coding assistant
    claude-code
    
    # Music & Media
    spotify
    vlc  # Media player
    mpv  # Lightweight video player
    ffmpeg  # Video/audio processing

    # Cloud storage
    dropbox

    # Communication
    signal-desktop 
    vesktop  # Discord client with Vencord built-in
    slack
    zoom-us

    # Screenshots & Screen Recording
    flameshot  # Screenshot tool
    obs-studio  # Screen recording/streaming
    
    # Document viewers
    kdePackages.okular  # PDF viewer (KDE)
    libreoffice-fresh  # Office suite
    
    # Image editing
    gimp  # Photo editor
    inkscape  # Vector graphics
    
    # System utilities
    gparted  # Partition manager
    htop  # Process viewer (alternative to btop)
    
    # Proton suite
    protonmail-bridge-gui  # GUI application with system tray
    protonvpn-gui
  ];

  # Create desktop entry for Proton Mail Bridge GUI with autostart
  xdg.configFile."autostart/protonmail-bridge.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Proton Mail Bridge
    GenericName=Email Bridge
    Comment=Proton Mail Bridge for desktop email clients
    Exec=protonmail-bridge-gui --no-window
    Icon=protonmail-bridge
    Terminal=false
    Categories=Network;Email;
    X-KDE-autostart-after=panel
  '';

  # JetBrains Toolbox autostart
  xdg.configFile."autostart/jetbrains-toolbox.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=JetBrains Toolbox
    GenericName=IDE Manager
    Comment=Manage JetBrains IDEs
    Exec=jetbrains-toolbox --minimize
    Icon=jetbrains-toolbox
    Terminal=false
    Categories=Development;
    X-KDE-autostart-after=panel
  '';

  # basic configuration of git, please change to your own
    programs.git = {
    enable = true;
    settings = {
      user = {
        name = "AlexTLDR";
        email = "alex.badragan@protonmail.com";
      };
    };
  };

 
  # Disabled in favor of Oh My Zsh themes
  # programs.starship = {
  #   enable = true;
  #   # custom settings
  #   settings = {
  #     add_newline = false;
  #     aws.disabled = true;
  #     gcloud.disabled = true;
  #     line_break.disabled = true;
  #   };
  # };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  
  programs.ghostty = {
    enable = true;
    settings = {
      # Font settings with Fira Code Nerd Font
      font-size = 12;
      font-family = "FiraCode Nerd Font";

      # Terminal behavior
      term = "xterm-256color";
      copy-on-select = true;

      # Appearance
      background-opacity = 0.95;
      theme = "Dracula";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Oh My Zsh configuration
    oh-my-zsh = {
      enable = true;
      theme = "agnoster"; 
      plugins = [
        "git"
        "docker"
        "kubectl"
        "golang"
        "rust"
        "npm"
        "node"
        "python"
        "vscode"
        "direnv"
        "command-not-found"
      ];
    };
    
    initContent = ''
      # PATH additions
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      k = "kubectl";
      d = "docker";
      dc = "docker-compose";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      nixos-rebuild-switch = "sudo nixos-rebuild switch --flake /etc/nixos#nixos --impure";
      nixos-update = "nix flake update && sudo nixos-rebuild switch --flake /etc/nixos#nixos --impure";
    };

  };

  # Use vim for terminal-based editing
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
