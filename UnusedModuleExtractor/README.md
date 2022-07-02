# Unsed Module Extractor

## Usage

```zsh
$ source main.sh [options] <directory-path>
```

## Options

```
-d, --double: using double quotes
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
