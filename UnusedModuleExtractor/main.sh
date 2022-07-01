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
#     tmp.sh <directory-path> [options]
#
# Options:
#     -d, --double: using double quotes           TODO: implement
#     -s, --single: using single quotes           TODO: implement
#     -o, --output <file-name>: output to file    TODO: implement



# Use single or double quotes, depending on the situation
# Use single quotes by default
delimiter="'"
# delimiter="\""

usingModulePaths=()
targetFilePaths=()
unusedModulePaths=()
targetExtensions=(".js" ".jsx" ".ts" ".tsx")

# Note: To use double quotation marks, rewrite the code as follows
#     moduleNameRetriver: 2
#     split($0, splited_line, "'$delimiter'");
#     split($0, splited_line, "\'$delimiter'");
moduleNameRetriver='
/^import.+from/{
    split($0, splited_line, "'$delimiter'");
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

for fileAbsolutePath in `find $1 -type f`; do
    fileName=$(echo $fileAbsolutePath | awk $splitter)
    fileExtension=${fileName##*.}
    fileNameWithoutExtension=${fileName%.*}

    if ! [[ "${targetExtensions[@]}" =~ "$fileExtension" ]]; then
        continue
    fi

    # Exclude file names with "index.<target extension>" as the file name.
    if [ "$fileNameWithoutExtension" = "index" ]; then
        continue
    fi

    targetFilePaths+=($fileNameWithoutExtension)
    usingModuleName=$(awk $moduleNameRetriver $fileAbsolutePath)
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
for fileAbsolutePath in `find $1 -type f`; do
    fileName=$(echo $fileAbsolutePath | awk $splitter)
    fileNameWithoutExtension=${fileName%.*}

    for unusedModulePath in ${unusedModulePaths[@]}; do
        if [[ $fileNameWithoutExtension == $unusedModulePath ]]; then
            echo $fileAbsolutePath >> unused.txt
        fi
    done
done
