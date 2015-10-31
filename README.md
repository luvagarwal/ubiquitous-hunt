# ubiquitous-hunt

A utility for linux shell which lets you just pass the file names and dir names and eliminate the need to provide complete path of the file or directory you want to specify in the command. It learns and prioritizes from the user's use of files and directories in the commands and use them at later stage to automatically determine the complete path of files. Suppose you have to run a command on bash in which you have to specify a file or directory (for example cd, mv, cp, du, etc) then it let you just specify the name of file or directory and would figure out the complete path itself. <br/><br/>
It may sound that this would be very slow as it has to search for the specified filename in the whole file system, which can be extremely slow, but it works in quite a different way and does not produce any noticeable change in the execution time of commands

1. It does not interfere in the command if it is executed successfully.
2. It automatically prioritizes the files and directories on the basis of how you use them in your commands and let you use them later without specifying the whole path.
3. It does not produce any noticeable change in the execution time of commands.
4. Even there is no need to specify the complete filename. Substrings of filename will work.
