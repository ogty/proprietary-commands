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
-D, --delete: delete the unused files
```

> **Warning**  
> This command does not perfectly output unused files.  
> The `-D, --delete` option should be avoided if possible.  
> If you do use it, please use it only in an environment where you can revert deleted files.

## Example

```zsh
$ source main.sh -d -o output.txt ./src
```

```
directoryPath: ./src
delimiter: "
outputFileName: output.txt
```
