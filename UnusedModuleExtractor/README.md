# Unsed Module Extractor

## Usage

```zsh
$ source main.sh [options] <directory-path>
```

## Options

```
-d, --double: using double quotes
-c, --confirm: Turn on confirmation to delete files
-s, --single: using single quotes
-o, --output <file-name>: output to file
-e, --exclude '<file-name> ...': exclude the files
-D, --delete: delete the unused files
```

> **Note**  
> Files specified with the `-e` option must be given with the file extension included.

> **Warning**  
> This command does not perfectly output unused files.  
> The `-D` option should be avoided if possible.  
> If you do use it, please use it only in an environment where you can revert deleted files.  
> Alternatively, please check the required files in advance and specify them with the `-e` option.

## Example

```zsh
$ source main.sh -d -o output.txt ./src
$ source main.sh -e 'main.tsx vite-env.d.ts' ./src
```

```
directoryPath: ./src
delimiter: "
outputFileName: output.txt
```

## Tips

Components used within unused components are recognized as used components.  
Therefore, if you delete an unused component, when you run the command again,  
the component that was used within the deleted component may appear as an unused component.  
So, if you delete a component, it is recommended that you execute the command multiple times.  
In that case, it is even better to add the `-c` option and delete files interactively.  
