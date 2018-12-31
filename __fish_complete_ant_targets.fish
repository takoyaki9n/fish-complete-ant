function __fish_complete_ant_targets -d "Print list of targets from build.xml and imported files"
    # Get a buildfile that will be used by ant command
    function __get_buildfile
        set -l tokens (commandline -co)
        set -l prev $tokens[1] # should be 'ant'
        set -l buildfile "build.xml"
        for token in $tokens[2..-1]
            switch $prev
            case -buildfile -file -f
                set buildfile $token
            end
            set prev $token
        end
        # return last one
        eval echo -n $buildfile
    end
    # Parse ant targets in the given build file
    function __parse_ant_targets
        set -l buildfile $argv[1]
        # An array of ant targets ignoring new lines in start-tags
        # This does not work as expected when a value includes '>' (e.g. <target name="foo>bar">)
        set -l targets (string join ' ' (cat $buildfile) | string match -ar '<target.*?>')
        for target in $targets
            # These do not work as expected when a value includes '"' (e.g. <target name="foo\"bar">)
            set -l target_name (string match -r 'name="(.*?)"' $target)
            set -l target_description (string match -r 'description="(.*?)"' $target)
            if test -n $target_name[2]
                echo -n $target_name[2]
                if test -n $target_description[2]
                    echo \t$target_description[2]
                end
            end
        end
    end

    set -l buildfile (__get_buildfile)
    if test -f $buildfile
        __parse_ant_targets $buildfile
    end
end

