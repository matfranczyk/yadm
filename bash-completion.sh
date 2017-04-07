# test if git completion is missing, but loader exists, attempt to load
if ! declare -F _git > /dev/null && declare -F _completion_loader > /dev/null; then
  _completion_loader git
fi

# only operate if git completion is present
if declare -F _git > /dev/null; then

  __yadm_internal_commands() { # TODO: make it possible to inspect yadm for this
    cat <<-EOF
      alt
      bootstrap
      clean
      clone
      config
      decrypt
      encrypt
      enter
      gitconfig
      help
      init
      list
      perms
      version
EOF
  }
  __yadm_global_switches() { # TODO: make it possible to inspect yadm for this
    cat <<-EOF
      -Y --yadm-dir
      --yadm-repo
      --yadm-config
      --yadm-encrypt
      --yadm-archive
      --yadm-bootstrap
EOF
  }

  _yadm() {

    local current=${COMP_WORDS[COMP_CWORD]}
    local penultimate=${COMP_WORDS[COMP_CWORD-1]}
    local antepenultimate=${COMP_WORDS[COMP_CWORD-2]}

    # echo
    # echo "COMP_WORDS:$COMP_WORDS<-"
    # echo "COMP_CWORD:$COMP_CWORD<-"
    # echo " COMP_LINE:$COMP_LINE<-"
    # echo
    # echo "COMPREPLY:$COMPREPLY<-"
    # echo "current:$current<-"
    # echo "penultimate:$penultimate<-"
    # echo "antepenultimate:$antepenultimate<-"
    # echo

    # local GIT_WORK_TREE="$(yadm gitconfig core.worktree)"
    local GIT_DIR="$HOME/.yadm/repo.git" # TODO: make it possible to inspect yadm for this

    case "$penultimate" in
      bootstrap)
        COMPREPLY=()
        return 0
      ;;
      config)
        # TODO: add more direct way to query yadm for this
        local config_list=$(yadm config | egrep '^  yadm|^  local')
        COMPREPLY=( $(compgen -W "$config_list -e" -- "$current") )
        return 0
		  ;;
      decrypt)
        COMPREPLY=( $(compgen -W "-l" -- "$current") )
        return 0
		  ;;
      init)
        COMPREPLY=( $(compgen -W "-f -w" -- "$current") )
        return 0
		  ;;
      help)
        COMPREPLY=() # no specific help yet
        return 0
      ;;
      list)
        COMPREPLY=( $(compgen -W "-a" -- "$current") )
        return 0
		  ;;
    esac

    case "$antepenultimate" in
      clone)
        COMPREPLY=( $(compgen -W "-f -w --bootstrap --no-bootstrap" -- "$current") )
        return 0
		  ;;
    esac

    # this condition is so files are completed properly for --yadm-xxx options
    if [[ ! "$penultimate" =~ ^- ]]; then
      # TODO: somehow solve the problem with [--yadm-xxx option] being
      #       incompatible with what git expects, namely [--arg=option]
      _git
    fi
    if [[ "$current" =~ ^- ]]; then
      local matching=$(compgen -W "$(__yadm_global_switches)" -- "$current")
      __gitcompappend "$matching"
    fi

    if [ $COMP_CWORD == 1 ] || [[ "$antepenultimate" =~ ^- ]] ; then
      local matching=$(compgen -W "$(__yadm_internal_commands)" -- "$current")
      __gitcompappend "$matching"
    fi

  }

	complete -o bashdefault -o default -o nospace -F _yadm yadm 2>/dev/null \
		|| complete -o default -o nospace -F _yadm yadm

fi
