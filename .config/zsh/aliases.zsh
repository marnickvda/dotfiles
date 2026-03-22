alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

alias vim=nvim

alias g=git

alias dotfiles="nvim $HOME/dotfiles"

alias k=kubectl

alias pn="pnpm"
alias python=python3
alias pip=pip3

# https://www.youtube.com/watch?v=ua1FAlHt_Ys&t=232s
alias weather="curl http://wttr.in/"

fast-pr() {
  local open_browser=false
  local desc=""
  for arg in "$@"; do
    case "$arg" in
      --browser|-b) open_browser=true ;;
      *) desc="$arg" ;;
    esac
  done
  [[ -z "$desc" ]] && { echo "Usage: fast-pr [-b|--browser] \"docs: add plan on xyz\""; return 1; }
  local branch="fast-pr-$(date +%Y%m%d-%H%M%S)"
  git add . && git stash && git pull && git switch -c "$branch" && git stash pop && git commit -am "$desc" && git push -u origin "$branch" || return 1
  local pr_url
  pr_url=$(gh pr create --title "$desc" --fill) || return 1
  echo "$pr_url"
  [[ "$open_browser" == true ]] && open "$pr_url"
}
