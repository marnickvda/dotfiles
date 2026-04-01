#!/bin/zsh
#
# brew-sync - Sync installed Homebrew packages with Brewfiles
#
# Compares what's currently installed against the layered Brewfiles
# (base + optional profile) and walks you through resolving differences.
#
# Usage: brew-sync [--dry-run]
#

function brew-sync {
    local dry_run=false
    [[ "$1" == "--dry-run" || "$1" == "-n" ]] && dry_run=true

    local brewfile_dir="${HOME}/.config/homebrew"
    local base_brewfile="${brewfile_dir}/Brewfile"
    local profile_brewfile=""

    if [[ -n "$ZSH_PROFILE" ]]; then
        profile_brewfile="${brewfile_dir}/Brewfile.${ZSH_PROFILE}"
    fi

    # --- Gather current state ---
    echo "Scanning installed packages..."

    local tmpdir
    tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT

    # Dump everything currently installed
    command brew bundle dump --file="$tmpdir/installed" --force >/dev/null 2>&1

    # Parse installed packages into categorized sets
    _brew_sync_parse "$tmpdir/installed" "$tmpdir/installed"
    _brew_sync_parse "$base_brewfile" "$tmpdir/base"
    if [[ -n "$profile_brewfile" && -f "$profile_brewfile" ]]; then
        _brew_sync_parse "$profile_brewfile" "$tmpdir/profile"
    else
        # Empty profile files so diff logic works
        for type in tap brew cask vscode go uv; do
            touch "$tmpdir/profile.$type"
        done
    fi

    # --- Compute diffs per category ---
    local has_diffs=false
    local -a categories=("tap" "brew" "cask" "vscode" "go" "uv")
    local -a category_labels=("Taps" "Formulae" "Casks" "VS Code extensions" "Go packages" "UV packages")

    # Combine base + profile into "expected"
    for type in "${categories[@]}"; do
        sort -u "$tmpdir/base.$type" "$tmpdir/profile.$type" > "$tmpdir/expected.$type" 2>/dev/null
    done

    echo ""

    # Track items for each scenario
    local -a missing_from_brewfiles  # installed but not in any Brewfile
    local -a not_installed           # in Brewfile but not installed

    for i in {1..${#categories}}; do
        local type="${categories[$i]}"
        local label="${category_labels[$i]}"

        # Installed but not in any Brewfile
        local -a extra=("${(@f)$(comm -23 "$tmpdir/installed.$type" "$tmpdir/expected.$type" 2>/dev/null)}")
        # In Brewfile(s) but not installed
        local -a missing=("${(@f)$(comm -13 "$tmpdir/installed.$type" "$tmpdir/expected.$type" 2>/dev/null)}")

        # Filter empty entries
        extra=(${extra:#})
        missing=(${missing:#})

        if [[ ${#extra} -gt 0 || ${#missing} -gt 0 ]]; then
            has_diffs=true
            echo "--- $label ---"

            if [[ ${#extra} -gt 0 ]]; then
                echo ""
                echo "  Installed but not tracked in any Brewfile:"
                for pkg in "${extra[@]}"; do
                    echo "    + $pkg"
                done
            fi

            if [[ ${#missing} -gt 0 ]]; then
                echo ""
                echo "  In Brewfile but not installed:"
                for pkg in "${missing[@]}"; do
                    echo "    - $pkg"
                done
            fi
            echo ""
        fi
    done

    if [[ "$has_diffs" == false ]]; then
        echo "Everything is in sync."
        return 0
    fi

    # --- Interactive walkthrough ---
    if [[ "$dry_run" == true ]]; then
        echo "(dry-run mode, no changes will be made)"
        return 0
    fi

    echo "============================================"
    echo ""
    echo "How to resolve these differences:"
    echo ""
    echo "  For packages INSTALLED but NOT TRACKED:"
    echo "    [b] Add to base Brewfile (available on all machines)"
    if [[ -n "$ZSH_PROFILE" ]]; then
        echo "    [p] Add to $ZSH_PROFILE Brewfile (${ZSH_PROFILE}-only)"
    fi
    echo "    [u] Uninstall the package"
    echo "    [s] Skip (leave as-is)"
    echo ""
    echo "  For packages TRACKED but NOT INSTALLED:"
    echo "    [i] Install it now"
    echo "    [r] Remove from Brewfile"
    echo "    [s] Skip (leave as-is)"
    echo ""

    printf "Proceed with interactive walkthrough? [Y/n] "
    read -r proceed
    if [[ "$proceed" == "n" || "$proceed" == "N" ]]; then
        return 0
    fi

    echo ""

    # Process installed-but-not-tracked packages
    for type in "${categories[@]}"; do
        local -a extra=("${(@f)$(comm -23 "$tmpdir/installed.$type" "$tmpdir/expected.$type" 2>/dev/null)}")
        extra=(${extra:#})

        for pkg in "${extra[@]}"; do
            local full_line="$(_brew_sync_format_line "$type" "$pkg")"
            echo "INSTALLED but NOT TRACKED: $full_line"

            local valid=false
            while [[ "$valid" == false ]]; do
                if [[ -n "$ZSH_PROFILE" ]]; then
                    printf "  [b]ase / [p]rofile / [u]ninstall / [s]kip? "
                else
                    printf "  [b]ase / [u]ninstall / [s]kip? "
                fi
                read -r choice
                case "$choice" in
                    b)
                        echo "$full_line" >> "$base_brewfile"
                        echo "  -> Added to $base_brewfile"
                        valid=true
                        ;;
                    p)
                        if [[ -n "$ZSH_PROFILE" ]]; then
                            echo "$full_line" >> "$profile_brewfile"
                            echo "  -> Added to $profile_brewfile"
                            valid=true
                        else
                            echo "  No profile set, choose another option."
                        fi
                        ;;
                    u)
                        echo "  -> Uninstalling $pkg..."
                        case "$type" in
                            tap)  command brew untap "$pkg" ;;
                            brew) command brew uninstall "$pkg" ;;
                            cask) command brew uninstall --cask "$pkg" ;;
                            *)    echo "  Manual removal needed for $type entries." ;;
                        esac
                        valid=true
                        ;;
                    s)
                        echo "  -> Skipped"
                        valid=true
                        ;;
                    *)
                        echo "  Invalid choice."
                        ;;
                esac
            done
            echo ""
        done
    done

    # Process tracked-but-not-installed packages
    for type in "${categories[@]}"; do
        local -a missing=("${(@f)$(comm -13 "$tmpdir/installed.$type" "$tmpdir/expected.$type" 2>/dev/null)}")
        missing=(${missing:#})

        for pkg in "${missing[@]}"; do
            local full_line="$(_brew_sync_format_line "$type" "$pkg")"

            # Determine which file(s) it's in
            local in_base=false in_profile=false
            grep -qF "$pkg" "$tmpdir/base.$type" 2>/dev/null && in_base=true
            grep -qF "$pkg" "$tmpdir/profile.$type" 2>/dev/null && in_profile=true

            local location=""
            if [[ "$in_base" == true && "$in_profile" == true ]]; then
                location="(in base + $ZSH_PROFILE)"
            elif [[ "$in_base" == true ]]; then
                location="(in base)"
            elif [[ "$in_profile" == true ]]; then
                location="(in $ZSH_PROFILE)"
            fi

            echo "TRACKED but NOT INSTALLED: $full_line $location"

            local valid=false
            while [[ "$valid" == false ]]; do
                printf "  [i]nstall / [r]emove from Brewfile / [s]kip? "
                read -r choice
                case "$choice" in
                    i)
                        echo "  -> Installing $pkg..."
                        case "$type" in
                            tap)  command brew tap "$pkg" ;;
                            brew) command brew install "$pkg" ;;
                            cask) command brew install --cask "$pkg" ;;
                            *)    echo "  Manual install needed for $type entries." ;;
                        esac
                        valid=true
                        ;;
                    r)
                        if [[ "$in_base" == true ]]; then
                            _brew_sync_remove_entry "$base_brewfile" "$type" "$pkg"
                            echo "  -> Removed from base Brewfile"
                        fi
                        if [[ "$in_profile" == true ]]; then
                            _brew_sync_remove_entry "$profile_brewfile" "$type" "$pkg"
                            echo "  -> Removed from $ZSH_PROFILE Brewfile"
                        fi
                        valid=true
                        ;;
                    s)
                        echo "  -> Skipped"
                        valid=true
                        ;;
                    *)
                        echo "  Invalid choice."
                        ;;
                esac
            done
            echo ""
        done
    done

    echo "Done. You may want to review and commit your Brewfile changes."
}

# Parse a Brewfile into sorted per-type files: <prefix>.tap, <prefix>.brew, etc.
_brew_sync_parse() {
    local input="$1"
    local prefix="$2"

    for type in tap brew cask vscode go uv; do
        touch "$prefix.$type"
    done

    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" == \#* ]] && continue

        local type="${line%% *}"
        # Extract the package name (first quoted string)
        local pkg=$(echo "$line" | sed -n 's/^[a-z]* "\([^"]*\)".*/\1/p')

        [[ -z "$pkg" ]] && continue

        case "$type" in
            tap|brew|cask|vscode|go|uv)
                echo "$pkg" >> "$prefix.$type"
                ;;
        esac
    done < "$input"

    # Sort each file in place for comm
    for type in tap brew cask vscode go uv; do
        sort -u -o "$prefix.$type" "$prefix.$type"
    done
}

# Format a type + package name back into Brewfile syntax
_brew_sync_format_line() {
    local type="$1"
    local pkg="$2"
    echo "$type \"$pkg\""
}

# Remove an entry from a Brewfile by type and package name
_brew_sync_remove_entry() {
    local file="$1"
    local type="$2"
    local pkg="$3"

    local escaped_pkg="${pkg//\//\\/}"
    sed -i '' "/^${type} \"${escaped_pkg}\"/d" "$file"
}
