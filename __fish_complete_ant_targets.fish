function __fish_complete_ant_targets -d "Print list of targets from build.xml and imported files"
    # Get a buildfile that will be used by ant command ($argv must be tokens from 'commandline -co')
    function __get_buildfile
        set -l prev $argv[1] # should be 'ant'
        set -l buildfile "build.xml"
        for token in $argv[2..-1]
            switch $prev
            case -buildfile -file -f
                set buildfile (eval echo $token)
            end
            set prev $token
        end
        # return last one
        echo $buildfile
    end
    # Parse ant targets in the given build file ($argv[1] must be a full path to an existing buildfile)
    function __parse_ant_targets
        set -l buildfile $argv[1]
        # An array of ant targets ignoring new lines in start-tags
        # NOTE: This does not work as expected when a value includes '>' (e.g. <target name="foo>bar">)
        set -l targets (string join ' ' (cat $buildfile) | string match -ar '<(?:target|extension-point).*?>')
        for target in $targets
            # NOTE: These do not work as expected when a value includes '"' (e.g. <target name="foo\"bar">)
            set -l target_name (string match -r 'name="(.*?)"' $target)[2]
            if [ $status -eq 0 ]
                set -l target_description (string match -r 'description="(.*?)"' $target)[2]
                if [ $status -eq 0 ]
                    echo $target_name\t$target_description
                else
                    echo $target_name
                end
            end
        end
    end
    # Get ant targets recursively ($argv[1] must be a full path to an existing buildfile)
    function __get_ant_targets
        set -l buildfile $argv[1]
        __parse_ant_targets $buildfile

        set -l basedir (string split -r -m 1 / $buildfile)[1]
        set -l imports (string join ' ' (cat $buildfile) | string match -ar '<(?:import).*?>')
        for import in $imports
            set -l filepath (string match -r 'file="(.*?)"' $import)[2]
            # Set basedir if $filename is not a full path
            if string match -rq '^[^/].*' $filepath
                set filename $basedir/$filepath
            end
            if realpath -eq $filepath
                __get_ant_targets $filepath
            end
        end
    end

    set -l tokens (commandline -co)
    set -l buildfile (realpath -eq $buildfile (__get_buildfile $tokens))
    if [ $status -eq 0 ]
        __get_ant_targets $buildfile
    end
end