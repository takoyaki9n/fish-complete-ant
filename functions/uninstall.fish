if [ \( -z "$XDG_CACHE_HOME" \) -o \( ! -d "$XDG_CACHE_HOME" \) ]
    set cache_dir "$HOME/.cache/fish/ant_completions"
else
    set cache_dir "$XDG_CACHE_HOME/fish/ant_completions"
end

if test -e $cache_dir
    echo -s (set_color red) \
        "Remove $cache_dir to uninstall fish-complete-ant completely." \
        (set_color normal) >/dev/stderr
end
