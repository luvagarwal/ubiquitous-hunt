# Ubiquitous Hunt

A linux shell utility which lets you pass incomplete paths in bash commands. One quick usage exmaple would be to run `cd ghi` instead of `cd abc/def/ghi` after installing ubiquitous hunt.

## How it works?
It works by checking for errors in command output and trying to modify the command in order to successfully execute it.

1. It does not interfere in the command if it is executed successfully.
2. In case of failure, it will identify if the reason for failure is related to incomplete path or not (by doing regex pattern matching on stderr).
3. If the reason for failure is something else, it will exit. Else, it will replace the incomplete paths with complete paths using locate command and again run the command.
4. It will keep on replacing until the command is successfully executed or nothing more it can do.

## Sample commands

Commands with single file/dir path argument (cd, ls, grep, head, tail, cat, du, stat, chown, etc)
```
$ cd ubiquitous-hunt
Executing builtin cd /home/fnatic9910/gitrepos/ubiquitous-hunt
~/gitrepos/ubiquitous-hunt$ cd feedback
Executing builtin cd /home/fnatic9910/gitrepos/feedback
~/gitrepos/feedback$ cd
$ grep feedback -rn -e "blah!"
Executing /bin/grep /home/fnatic9910/gitrepos/feedback -rn -e blah! 

```

Commands with multiple file/dir path arguments (mv, cp, diff, cmp, etc)
```
$ mv test feedback/ # Note trailing slash. Without it, command would be successfully executed if test exists
Executing /bin/mv /home/fnatic9910/gitrepos/feedback
$ mv Ass2.tar.gz feedback/
Executing /bin/mv /home/fnatic9910/Downloads/Ass2.tar.gz feedback/
Executing /bin/mv /home/fnatic9910/Downloads/Ass2.tar.gz /home/fnatic9910/gitrepos/feedback
```
Note in second mv command `mv Ass2.tar.gz feedback/`, it failed, did path replacement for `Ass2.tar.gz`, failed, did path replacement for `feedback/`, executed successfully.

## Installation
Download this repository and source makealias.sh into your .bashrc or other startup script.

## Todos

- [ ] Better handling in case of path collisions by logging recent usage of files
- [ ] Allow incomplete file names
