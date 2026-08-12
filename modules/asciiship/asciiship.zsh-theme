# vim:et sts=2 sw=2 ft=zsh

_prompt_asciiship_vimode() {
  case ${KEYMAP} in
    vicmd) print -n '%S%(!.#.)%s' ;;
    *) print -n '%(!.#.)' ;;
  esac
}

_prompt_asciiship_keymap_select() {
  zle reset-prompt
  zle -R
}
if autoload -Uz is-at-least && is-at-least 5.3; then
  autoload -Uz add-zle-hook-widget && \
    add-zle-hook-widget -Uz keymap-select _prompt_asciiship_keymap_select
else
  zle -N zle-keymap-select _prompt_asciiship_keymap_select
fi

typeset -gx VIRTUAL_ENV_DISABLE_PROMPT=1

setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
zmodload zsh/terminfo 2>/dev/null || true
typeset -gA terminfo

# Use True color (24-bit) if available.
if [[ "${terminfo[colors]}" -ge 256 ]]; then
  azim_dark="%F{0}"
  azim_turquoise="%F{73}"
  azim_orange="%F{179}"
  azim_red="%F{167}"
  azim_limegreen="%F{107}"
  azim_bg_limegreen="%K{107}"
  azim_bg_orange="%K{179}"
  azim_bg_red="%K{167}"
  azim_bg_subtle="%K{236}"
  azim_bg_turquoise="%K{73}"
  azim_subtle="%F{236}"
  azim_magenta="%F{177}"
else
  azim_dark="%F{black}"
  azim_turquoise="%F{cyan}"
  azim_orange="%F{yellow}"
  azim_red="%F{red}"
  azim_limegreen="%F{green}"
  azim_bg_limegreen="%K{green}"
  azim_bg_orange="%K{yellow}"
  azim_bg_red="%K{red}"
  azim_bg_subtle="%K{black}"
  azim_bg_turquoise="%K{cyan}"
  azim_subtle="%F{black}"
  azim_magenta="%F{magenta}"
fi
# Reset color.
azim_reset_color="%f"
azim_reset_bg="%k"

# Depends on git-info module to show git information
typeset -gA git_info

if (( ${+functions[git-info]} )); then
  zstyle ':zim:git-info' verbose yes
  zstyle ':zim:git-info:branch' format '%b'
  zstyle ':zim:git-info:commit' format "HEAD %{$azim_limegreen%}(%c)%{$azim_reset_color%}"
  zstyle ':zim:git-info:action' format "(%{$azim_magenta%}%a%{$azim_reset_color%})"
  zstyle ':zim:git-info:stashed' format " %{$azim_limegreen%}%{$azim_reset_color%}"
  zstyle ':zim:git-info:unindexed' format " %{$azim_orange%}!%{$azim_reset_color%}"
  zstyle ':zim:git-info:untracked' format " %{$azim_red%}?%{$azim_reset_color%}"
  zstyle ':zim:git-info:indexed' format " %{$azim_limegreen%}↑%{$azim_reset_color%}"
  zstyle ':zim:git-info:ahead' format " %{$azim_magenta%}>%{$azim_reset_color%}"
  zstyle ':zim:git-info:behind' format " %{$azim_turquoise%}<%{$azim_reset_color%}"
  case ${AKIRON_ZSH_PROMPT_STYLE:-compact} in
    segments)
      zstyle ':zim:git-info:keys' format \
        'status' '%S%I%u%i%A%B' \
        'prompt' "%{$azim_turquoise%} %b%{$azim_reset_color%}%s\${git_info[status]:+\"\${git_info[status]}\"}"
      ;;
    *)
      zstyle ':zim:git-info:keys' format \
        'status' '%S%I%u%i%A%B' \
        'prompt' "on %{$azim_turquoise%} %b%{$azim_reset_color%}%s\${git_info[status]:+\"\${git_info[status]}\"}"
      ;;
  esac
  add-zsh-hook precmd git-info
fi

_prompt_asciiship_user_host_segment() {
  if (( EUID == 0 )); then
    print -n "%B%{$azim_red%}%n%{$azim_reset_color%}%b in "
  elif [[ -n ${SSH_TTY} ]]; then
    local username=${USER}
    local -u initial=${username:0:1}
    print -n "%{$azim_limegreen%}${initial}${username:1}%{$azim_reset_color%} at %{$azim_limegreen%}%m%{$azim_reset_color%} in "
  fi
}

_prompt_asciiship_segments_user_host_segment() {
  if (( EUID == 0 )); then
    print -n "%{$azim_red%}%{$azim_bg_red%}%{$azim_dark%}%B %n %b%{$azim_reset_bg%}%{$azim_reset_color%}%{$azim_red%}%{$azim_reset_color%} "
  elif [[ -n ${SSH_TTY} ]]; then
    local username=${USER}
    local -u initial=${username:0:1}
    print -n "%{$azim_turquoise%}%{$azim_bg_turquoise%}%{$azim_dark%} ${initial}${username:1} %{$azim_reset_bg%}%{$azim_reset_color%}%{$azim_turquoise%}%{$azim_reset_color%} "
  fi
}

_prompt_asciiship_path_segment() {
  print -n "%{$azim_limegreen%} %~%{$azim_reset_color%}"
}

_prompt_asciiship_expand_prompt() {
  local prompt_text=${1-}
  eval "prompt_text=\"${prompt_text}\""
  eval "prompt_text=\"${prompt_text}\""
  print -n -- "${prompt_text}"
}

_prompt_asciiship_git_segment() {
  _prompt_asciiship_expand_prompt "${git_info[prompt]}"
}

_prompt_asciiship_env_segment() {
  [[ -n ${VIRTUAL_ENV} ]] && print -n -- " via %{$azim_orange%}${VIRTUAL_ENV:t}%{$azim_reset_color%}"
  [[ -n ${CONDA_DEFAULT_ENV} ]] && print -n -- " via %{$azim_orange%}${CONDA_DEFAULT_ENV:t}%{$azim_reset_color%}"
  return 0
}

_prompt_asciiship_segments_path_segment() {
  print -n "%{$azim_limegreen%}%{$azim_bg_limegreen%}%{$azim_dark%}  %~ %{$azim_reset_bg%}%{$azim_reset_color%}%{$azim_limegreen%}%{$azim_reset_color%} "
}

_prompt_asciiship_segments_git_segment() {
  local git_prompt
  git_prompt=$(_prompt_asciiship_expand_prompt "${git_info[prompt]}")
  [[ -n ${git_prompt} ]] && print -n -- "%{$azim_subtle%}%{$azim_bg_subtle%} ${git_prompt} %{$azim_reset_bg%}%{$azim_subtle%}%{$azim_reset_color%} "
}

_prompt_asciiship_segments_env_segment() {
  [[ -n ${VIRTUAL_ENV} ]] && print -n -- "%{$azim_orange%}%{$azim_bg_orange%}%{$azim_dark%}  ${VIRTUAL_ENV:t} %{$azim_reset_bg%}%{$azim_reset_color%}%{$azim_orange%}%{$azim_reset_color%} "
  [[ -n ${CONDA_DEFAULT_ENV} ]] && print -n -- "%{$azim_orange%}%{$azim_bg_orange%}%{$azim_dark%}  ${CONDA_DEFAULT_ENV:t} %{$azim_reset_bg%}%{$azim_reset_color%}%{$azim_orange%}%{$azim_reset_color%} "
  return 0
}

typeset -g _prompt_asciiship_compact_ps1="
\$(_prompt_asciiship_user_host_segment)\$(_prompt_asciiship_path_segment) \$(_prompt_asciiship_git_segment)\$(_prompt_asciiship_env_segment)
%(?.%{$azim_limegreen%}.%{$azim_red%})\$(_prompt_asciiship_vimode)%{$azim_reset_color%} "

typeset -g _prompt_asciiship_segments_ps1="
\$(_prompt_asciiship_segments_user_host_segment)\$(_prompt_asciiship_segments_path_segment)\$(_prompt_asciiship_segments_git_segment)\$(_prompt_asciiship_segments_env_segment)
%(?.%{$azim_limegreen%}.%{$azim_red%})\$(_prompt_asciiship_vimode)%{$azim_reset_color%} "

case ${AKIRON_ZSH_PROMPT_STYLE:-compact} in
  segments)
    PS1=${_prompt_asciiship_segments_ps1}
    ;;
  compact|*)
    PS1=${_prompt_asciiship_compact_ps1}
    ;;
esac

unset RPS1
