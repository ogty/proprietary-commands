#!/bin/sh

# Description:
#     This command is used to identify unused components in a SPA project.
#     Unused files are written to "unsed.txt" with absolute paths.
#     It will identify unused components in the following ways:
#
#         1. Match any extension of ".js", ".jsx", ".ts", ".tsx".
#         2. Matching file is called in the form of "import from".
#         3. Obtains the characters after "from" and determines if they match the file name.
#            If the file name is "index", do not include the file.
#         4. Compare the file directly under the specified directory with the characters after "from".
#         5. If there is no match, it is assumed to be an unused component.
#         6. Output to file
#
# Usage:
#     source main.sh [options] <directory-path>
#
# Options:
#     -d, --double: using double quotes
#     -s, --single: using single quotes
#     -o, --output <file-name>: output to file
#     -D, --delete: delete the unused files
#
# Examples:
#     source main.sh -s -o output.txt ./src
#
# Warning:
#     This command does not perfectly output unused files.
#     The "-D, --delete" option should be avoided if possible.
#     If you do use it, please use it only in an environment where you can revert deleted files.



# Use single or double quotes, depending on the situation
delimiter="'"               # Use single quotes by default
outputFileName="unused.txt" # default output file name

usingModulePaths=()
targetFilePaths=()
unusedModulePaths=()
targetExtensions=(".js" ".jsx" ".ts" ".tsx")

while [ $# -gt 0 ]; do
    case "$1" in
        -d|--double)
            delimiter="\""
            ;;
        -s|--single)
            delimiter="'"
            ;;
        -o|--output)
            shift
            outputFileName="$1"
            ;;
        -D|--delete)
            delete=true
            ;;
        *)
            # if no option, assume it is the directory path
            if [ -z "$directoryPath" ]; then
                directoryPath="$1"
            else
                echo "Invalid option: $1"
                exit 1
            fi
            ;;
    esac
    shift
done

# Confirmation regarding delete option
if [ "$delete" = true ]; then
    echo "Are you sure you want to delete the unused files?"
    echo "Type 'yes' to continue: "
    read answer
    if [ "$answer" != "yes" ]; then
        echo "Aborting..."
        exit 1
    fi
fi

# Note: To use double quotation marks, rewrite the code as follows
#     moduleNameRetriver: 2
#     split($0, splited_line, "'$delimiter'");
#     split($0, splited_line, "\'$delimiter'");
moduleNameRetriver='
BEGIN {
    FS = "'$delimiter'";
}

/^import.+from/{
    split($0, splited_line, FS);
    module_path = splited_line[2];

    split(module_path, splited_module_path, "/");
    splited_module_path_length = length(splited_module_path);

    print(splited_module_path[splited_module_path_length]);
}
'

splitter='
{
    split($1, arr, "/");
    arr_length = length(arr);
    print(arr[arr_length]);
}
'

for fileAbsolutePath in `find $directoryPath -type f`; do
    fileName=$(echo $fileAbsolutePath | awk $splitter)
    fileExtension=${fileName##*.}
    fileNameWithoutExtension=${fileName%.*}

    if ! [[ "${targetExtensions[@]}" =~ "$fileExtension" ]]; then
        continue
    fi

    targetFilePaths+=($fileNameWithoutExtension)
    usingModuleName=$(awk -F "$delimiter" $moduleNameRetriver $fileAbsolutePath)
    usingModulePaths+=($usingModuleName)
done

# Remove duplicates
usingModulePaths=($(echo "${usingModulePaths[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Store unmatched modules in array
for targetFilePath in ${targetFilePaths[@]}; do
    if [[ ! ${usingModulePaths[@]} =~ $targetFilePath ]]; then
        unusedModulePaths+=($targetFilePath)
    fi
done

# Remove duplicates
unusedModulePaths=($(echo "${unusedModulePaths[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

# Output absolute paths of unused modules to file
for fileAbsolutePath in `find $directoryPath -type f`; do
    fileName=$(echo $fileAbsolutePath | awk $splitter)
    fileNameWithoutExtension=${fileName%.*}

    for unusedModulePath in ${unusedModulePaths[@]}; do
        if [[ $fileNameWithoutExtension == $unusedModulePath ]]; then
            if [ "$fileNameWithoutExtension" != "index" ]; then
                echo $fileAbsolutePath >> $outputFileName
                if [ "$delete" = true ]; then
                    rm $fileAbsolutePath
                fi
            fi
        fi
    done
done
