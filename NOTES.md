# GIT

## I'm not comfortable with git. Where can I learn it? 
There are numerous tutorials to learn git. Keep in mind that the workflow at COMPANY may differ from the ones in the
tutorial when it comes to posting the changes for review, git-svn, etc...
 
* [Learning Gig Branching](http://learngitbranching.js.org/) - Is an interactive tutorial. It allows you to visualize the git history with each command. It's great for beginners and advanced git users.
* [Command Line Essentials :Git Bash for Windows](https://www.udemy.com/git-bash/) - Udemy.com course
* [Git Start with GitHub](https://www.udemy.com/git-started-with-github/) - Udemy.com course
* [Try Git: Git Tutorial](https://try.github.io/levels/1/challenges/1) -
* [Git Tower](https://www.git-tower.com/learn/) -
* [Git From the Inside out](https://codewords.recurse.com/issues/two/git-from-the-inside-out) - 

## Using GIT frontend with an SVN backend
1. Install git by following instructions on https://git-scm.com/
1. Ensure `git svn` is installed.
1. Open a terminal and change directories to where you want to store the repository
1. Type the following: 

    `git svn clone --stdlayout --prefix=origin/ <SVN_REPO_ROOT_URL>` 
    
    **NOTE:**  Depending on the size of the SVN repo, this command may take a few hours to complete
     as it's looking at each SVN commit and creating a respective git commit. If you don't want all
     the SVN history, add the following command line   argument prior to providing the SVN repo URL
  
    `--revision ####` 
    
    where `####` is the revision number, to the `git svn clone` command. If you don't care about the SVN history, 
    use the following command:
    
    `git svn clone --stdlayout --revision HEAD --prefix=origin/ <SVN_REPO_ROOT_URL>` 
  
1. Now you have a git front-end with an SVN back-end. That is, a git repo representation of the SVN automation repo.
1. According to [this post](https://spin.atomicobject.com/2014/08/17/git-svn-empty-directories/), git treats directories as files, 
while SVN makes the distinction between directories and files. Thus, removing directories from git-svn may not remove 
the directory from the SVN repo. As a result, let's configure git-svn to automatically remove directory. Run the 
following:

    `git config --global svn.rmdir true`


### Using ReviewBoard for code reviews?
If you are using ReviewBoard for code reviews, you will need to manually setup a `.reviewboardrc` file to use the
`rbt` tooling to automatically post reviews.  Create the following `.reviewboardrc` file in the `git` repository 
root

    
    REVIEWBOARD_URL = "<REVIEWBOARD_URL"
    REPOSITORY = "<SVN repo name>"
    BRANCH = "master"
    TRACKING_BRANCH = "remotes/origin/trunk"
    
    
where

* `REVIEWBOARD_URL` is the URL (including protocol) to the reviewboard server.  e.g.:  http://reviewboard.compnany.com
* `REPOSITORY` is the SVN repository name as it appears on reviewboard.
* Set `BRANCH` to point to the target branch where the changes should be diffed against

### `git svn` command does not exist.  What do I do?

If you encounter a problem similar to

    $ git svn -h
    git: 'svn' is not a git command. See 'git --help'.
    
    Did you mean this?
            fsck
            show

It means the git-svn option is not installed on your system. Search the internet for instructions on how to install 
it for your current OS. [This stackoverflow](https://stackoverflow.com/questions/527037/git-svn-not-a-git-command)
 post might be a good starting point
