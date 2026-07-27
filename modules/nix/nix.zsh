# Only load if Nix is available
command -v nix >/dev/null 2>&1 || return 0

# ── nixos-rebuild (NixOS only) ──────────────────────────────────────────────
if command -v nixos-rebuild >/dev/null 2>&1; then
  alias nxswitch='sudo nixos-rebuild switch --flake .'
  alias nxtest='sudo nixos-rebuild test --flake .'
  alias nxboot='sudo nixos-rebuild boot --flake .'
fi

# ── nix profile ─────────────────────────────────────────────────────────────
if nix profile history --help >/dev/null 2>&1; then
  if [[ -e /nix/var/nix/profiles/system ]]; then
    alias nxhistory='nix profile history --profile /nix/var/nix/profiles/system'
  fi
fi

# ── nix flake ───────────────────────────────────────────────────────────────
alias nxupdate='nix flake update'
alias nxshow='nix flake show'
alias nxcheck='nix flake check'
alias nxnew='nix flake new'
alias nxdev='nix develop'
alias nxbuild='nix build'

# ── nxgc: Nix garbage collection ────────────────────────────────────────────
function nxgc() {
  function _nxgc_all() {
    if command -v nixos-rebuild >/dev/null 2>&1; then
      sudo nix profile wipe-history --profile /nix/var/nix/profiles/system 2>/dev/null
      sudo nix-collect-garbage -d
    fi
    nix-collect-garbage -d
  }

  local older_than=${1:-7d}

  if [[ "$1" == "--all" || "$1" == "-a" ]]; then
    _nxgc_all
  else
    if command -v nixos-rebuild >/dev/null 2>&1; then
      sudo nix profile wipe-history --older-than "$older_than" --profile /nix/var/nix/profiles/system 2>/dev/null
      sudo nix-collect-garbage -d --delete-older-than "$older_than"
    fi
    nix-collect-garbage -d --delete-older-than "$older_than"
  fi
}

# ── nxrun: nix run (with smart package resolution) ──────────────────────────
function nxrun() {
  if (( $# == 0 )); then
    echo "Usage: nxrun <package> [-- args...]" >&2
    return 1
  fi

  local pkg=$1
  local name
  shift
  case "$pkg" in
    github:*|.*|/*|*#*) name=$pkg ;;  # GitHub refs, local paths, flake refs
    *) name="nixpkgs#$pkg" ;;         # plain package name → nixpkgs
  esac
  nix run "$name" "$@"
}

# Adapt nxrun's shorthand syntax to Nix's native completion protocol.
function _nxrun() {
  local pkg=${words[2]}

  if (( CURRENT == 2 )); then
    case "$pkg" in
      github:*|.*|/*|*#*) ;;
      *)
        local ifs_bk=$IFS
        local suggestion
        local -a res suggestions

        IFS=$'\n'
        res=($(NIX_GET_COMPLETIONS=2 nix run "nixpkgs#$pkg" 2>/dev/null))
        IFS=$ifs_bk

        for suggestion in ${res:1}; do
          suggestion=${suggestion%%$'\t'*}
          suggestions+=("${suggestion#nixpkgs#}")
        done
        compadd -J nix -S '' -a suggestions
        return
        ;;
    esac
  fi

  local -a words=(nix run "${words[@]:1}")
  local CURRENT=$(( CURRENT + 1 ))
  case "${words[3]}" in
    github:*|.*|/*|*#*) ;;
    *) words[3]="nixpkgs#${words[3]}" ;;
  esac
  _nix
}
compdef _nxrun nxrun

# ── nxsearch: search nixpkgs ────────────────────────────────────────────────
if command -v jq >/dev/null 2>&1; then
  function nxsearch() {
    local name=$1
    nix search nixpkgs "$name" --json |
    jq -r --arg name "$name" '
        to_entries[] |
        (.key | gsub("^legacyPackages\\.x86_64-linux\\."; "")) as $k |
        select($k | test($name; "i")) |
        if (.value.description != null and .value.description != "") then
          "\($k)(\(.value.version)): \(.value.description)"
        elif (.value.version != null and .value.version != "") then
          "\($k)(\(.value.version))"
        else
          "\($k)"
        end
    '
  }
fi

# ── nx: nix shell with smart package resolution ─────────────────────────────
function nx() {
  local args=($@)
  local pkgs=()
  for pkg in "${args[@]}"; do
    case "$pkg" in
      github:*|.*|/*|*#*) pkgs+=("$pkg") ;;
      *) pkgs+=("nixpkgs#$pkg") ;;
    esac
  done
  echo "Entering shell with: ${pkgs[*]}"
  nix shell "${pkgs[@]}"
}

# ── nxhash: compute SRI hash for a file URL ────────────────────────────────
nxhash() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: nxhash [--both] [hash-type] <url>"
    echo "Example: nxhash sha512 https://example.com/file.tar.gz"
    echo "         nxhash --both sha256 https://example.com/file.tar.gz"
    return 1
  fi

  local both="false"
  local hash_type url raw_hash from_hint from_format help_out

  # Check for --both
  if [[ "$1" == "--both" ]]; then
    both="true"
    shift
  fi

  # Parse arguments
  if [[ $# -ge 2 ]]; then
    hash_type="$1"
    url="$2"
    case "$hash_type" in
      md5|sha1|sha256|sha512) ;;
      *)
        echo "Unsupported hash type: $hash_type"
        echo "Supported: md5, sha1, sha256, sha512"
        return 1
        ;;
    esac
  else
    hash_type="sha256"
    url="$1"
  fi

  if [[ -z "$url" ]]; then
    echo "Error: URL is missing"
    echo "Usage: nxhash [--both] [hash-type] <url>"
    return 1
  fi

  # Detect nix hash convert supported base32 option
  if help_out=$(nix hash convert --help 2>&1); then
    if echo "$help_out" | grep -q 'nix32'; then
      from_hint="nix32"
    elif echo "$help_out" | grep -q 'base32'; then
      from_hint="base32"
    else
      from_hint="nix32"
    fi
  else
    from_hint="nix32"
  fi

  # nix-prefetch-url output encoding: md5 is base16, others are base32/nix32
  if [[ "$hash_type" == "md5" ]]; then
    from_format="base16"
  else
    from_format="$from_hint"
  fi

  # Generate a safe file name
  safe_name=$(basename "$url" | sed -E 's/%[0-9A-Fa-f]{2}/_/g; s/[^a-zA-Z0-9._+-]/_/g')

  # Get raw hash
  raw_hash=$(nix-prefetch-url --type "$hash_type" --name "$safe_name" "$url" | tee /dev/tty | awk 'END{print $NF}')

  if [[ -z "$raw_hash" ]]; then
    echo "Failed to obtain hash from nix-prefetch-url"
    return 1
  fi

  if [[ "$both" == "true" ]]; then
    echo "Algorithm: $hash_type"
    echo "Raw ($from_format): $raw_hash"
    echo -n "SRI: "
    nix hash convert --hash-algo "$hash_type" --from "$from_format" --to sri "$raw_hash"
  else
    nix hash convert --hash-algo "$hash_type" --from "$from_format" --to sri "$raw_hash"
  fi
}

# ── home-manager ────────────────────────────────────────────────────────────
if command -v home-manager >/dev/null 2>&1; then
  alias hm='home-manager'
  alias hmswitch='home-manager switch --flake .#$(hostname -s)'

  if [[ -e "$HOME/.local/state/nix/profiles/home-manager" ]]; then
    alias hmhistory="nix profile history --profile $HOME/.local/state/nix/profiles/home-manager"
  fi

  function hmgc() {
    local hm_profile="$HOME/.local/state/nix/profiles/home-manager"

    if [[ ! -e "$hm_profile" ]]; then
      echo "Error: home-manager profile not found at $hm_profile"
      return 1
    fi

    if [[ "$1" == "--all" || "$1" == "-a" ]]; then
      nix profile wipe-history --profile "$hm_profile"
      nix-collect-garbage -d
    else
      local older_than=${1:-7d}
      nix profile wipe-history --older-than "$older_than" --profile "$hm_profile"
      nix-collect-garbage -d --delete-older-than "$older_than"
    fi
  }
fi
