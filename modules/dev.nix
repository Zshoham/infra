{ self, ... }: {

  flake.nixosModules.dev = { pkgs, pkgs-unstable, szpkgs, ... }: {
    imports = [ self.nixosModules.packages ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };

    programs.starship = {
      enable = true;
      package = szpkgs.starship;
    };

    programs.fish.enable = true;
    programs.zoxide.enable = true;

    environment.systemPackages = (with pkgs; [
      curl
      wget
      util-linux
      iputils
      inetutils
      openssh
      rsync
      time
      tzdata
      unzip
      zip
      moreutils
      fish
      fd
      jq
      ripgrep
      lsd
    ]) ++ (with pkgs-unstable; [
      leaf-markdown-viewer
    ]) ++ (with szpkgs; [
      git
      jujutsu
      zellij
      btop
      gdb
    ]);
  };
}
