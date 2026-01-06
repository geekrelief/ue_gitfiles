.gitattributes is for git lfs locking
.gitignore standard ignore for Unreal projects
reference-transaction goes into .git/hooks/reference-transaction used to clear lfs locks that were pushed (this was updated from https://github.com/negokaz/git-lfs-auto-unlock) by gemini to work on windows
UnlockGitLfsLocks.ps1 powershell script that unlocks all lfs locks