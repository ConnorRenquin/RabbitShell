{
  description = "Rabbit Shell - Connor's personal Quickshell desktop shell";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    matugen-config = {
      url = "github:ConnorRenquin/RabbitShell-Matugen";
      flake = false;
    };
  };

  outputs = inputs @ { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      mkRabbitShell = system:
        let
          pkgs = import nixpkgs { inherit system; };
          lib = pkgs.lib;

          quickshell = pkgs.quickshell;
          matugen = if pkgs ? matugen then pkgs.matugen else null;
          awww = if pkgs ? awww then pkgs.awww else null;

          nerdFont = name:
            if pkgs ? nerd-fonts && builtins.hasAttr name pkgs.nerd-fonts
            then builtins.getAttr name pkgs.nerd-fonts
            else null;

          fontPackages = builtins.filter (pkg: pkg != null) [
            (nerdFont "jetbrains-mono")
            (nerdFont "roboto-mono")
            (nerdFont "agave")
            (nerdFont "space-mono")
            (nerdFont "terminess-ttf")
            (nerdFont "symbols-only")
          ];

          runtimeInputs = builtins.filter (pkg: pkg != null) ([
            quickshell
            matugen
            awww
            pkgs.zenity
            pkgs.satty
            pkgs.mpv
            pkgs.fastfetch
            pkgs.ydotool

            # Commands used by Process/execDetached in the shell.
            pkgs.bash
            pkgs.coreutils
            pkgs.findutils
            pkgs.hyprland
            pkgs.hyprpicker
            pkgs.libnotify
            pkgs.wl-clipboard
            pkgs.networkmanager
            pkgs.bluez
            pkgs.xdg-utils
            pkgs.systemd
          ] ++ fontPackages);
        in
        pkgs.stdenvNoCC.mkDerivation {
          pname = "rabbit-shell";
          version = "0.1.0";
          src = lib.cleanSourceWith {
            src = ./.;
            filter = path: type:
              let
                base = baseNameOf path;
              in
              !(base == ".git" || base == "flake.lock" || base == "result");
          };

          propagatedUserEnvPkgs = runtimeInputs;

          installPhase = ''
runHook preInstall

mkdir -p "$out/share/rabbit-shell" "$out/share/rabbit-shell-matugen" "$out/bin"
cp -r . "$out/share/rabbit-shell"
cp -r ${inputs.matugen-config}/. "$out/share/rabbit-shell-matugen"

cat > "$out/bin/matugen" <<'EOF'
#!@runtimeShell@
set -e

export RABBIT_SHELL_MATUGEN="@out@/share/rabbit-shell-matugen"
config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
matugen_config_dir="$config_home/matugen"
mkdir -p "$matugen_config_dir"

if [ ! -e "$matugen_config_dir/config.toml" ]; then
  ln -s "$RABBIT_SHELL_MATUGEN/config.toml" "$matugen_config_dir/config.toml"
fi

if [ ! -e "$matugen_config_dir/templates" ]; then
  ln -s "$RABBIT_SHELL_MATUGEN/templates" "$matugen_config_dir/templates"
fi

exec "@realMatugen@/bin/matugen" "$@"
EOF
substituteInPlace "$out/bin/matugen" \
  --subst-var-by runtimeShell "${pkgs.runtimeShell}" \
  --subst-var-by out "$out" \
  --subst-var-by realMatugen "${matugen}"
chmod +x "$out/bin/matugen"

cat > "$out/bin/rabbit-shell" <<'EOF'
#!@runtimeShell@
set -e

export PATH="@out@/bin:@runtimePath@:$PATH"
export RABBIT_SHELL_SHARE="@out@/share/rabbit-shell"
export RABBIT_SHELL_MATUGEN="@out@/share/rabbit-shell-matugen"

config_dir="''${RABBIT_SHELL_CONFIG:-''${XDG_CONFIG_HOME:-$HOME/.config}/quickshell}"
if [ ! -f "$config_dir/shell.qml" ]; then
  config_dir="$RABBIT_SHELL_SHARE"
fi

exec "@quickshell@/bin/quickshell" -p "$config_dir" "$@"
EOF
substituteInPlace "$out/bin/rabbit-shell" \
  --subst-var-by runtimeShell "${pkgs.runtimeShell}" \
  --subst-var-by runtimePath "${lib.makeBinPath runtimeInputs}" \
  --subst-var-by out "$out" \
  --subst-var-by quickshell "${quickshell}"
chmod +x "$out/bin/rabbit-shell"

runHook postInstall
          '';

          meta = {
            description = "Connor's personal Quickshell desktop shell with runtime dependencies";
            mainProgram = "rabbit-shell";
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      packages = forAllSystems (system:
        let
          rabbit-shell = mkRabbitShell system;
        in
        {
          inherit rabbit-shell;
          default = rabbit-shell;
        });

      apps = forAllSystems (system: {
        rabbit-shell = {
          type = "app";
          program = "${self.packages.${system}.rabbit-shell}/bin/rabbit-shell";
        };
        default = self.apps.${system}.rabbit-shell;
      });

      nixosModules.default = { pkgs, ... }: {
        environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.rabbit-shell ];
      };

      homeModules.default = { pkgs, ... }: {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.rabbit-shell ];
      };
    };
}
