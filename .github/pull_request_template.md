<!--
  For Work In Progress Pull Requests, please use the Draft PR feature,
  see https://github.blog/2019-02-14-introducing-draft-pull-requests/ for further details
  For a timely review/response, please avoid force-pushing additional
  commits if your PR already received reviews or comments
  Before submitting a Pull Request, please ensure you've done the following:
  - 👷‍♀️ Create small PRs. In most cases this will be possible.
  - ✅ Provide tests for your changes.
  - 📝 Use descriptive commit messages.
  - 📗 Update any related documentation and include any relevant screenshots
-->

## What type of PR is this? (check all applicable)

- [ ] New Feature
- [ ] Bug Fix
- [ ] Documentation Update
- [ ] Style Update
- [ ] Refactor
- [ ] Tests
- [ ] Other tasks

## Description

## Related Tickets & Documents

<!--
For pull requests that relate or close an issue, please include them
below.  We like to follow [Github's guidance on linking issues to pull requests](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue).

For example having the text: "closes #1234" would connect the current pull
request to issue 1234.  And when we merge the pull request, Github will
automatically close the issue.
-->

- Closes #

## Added/updated tests?
_Goal is code coverage percentage at 80% and above._

- [ ] Yes
- [ ] No, and this is why: <!--please replace this line with details on why tests-->
      have not been included_
- [ ] I need help with writing tests

## Pre-merge checklist

- [ ] PR title follows semantic commit guidelines (e.g., `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`)

<!--
- feat: (new feature for the user, not a new feature for build script)
- fix: (bug fix for the user, not a fix to a build script)
- docs: (changes to the documentation)
- style: (formatting, missing semi colons, etc; no production code change)
- refactor: (refactoring production code, eg. renaming a variable)
- test: (adding missing tests, refactoring tests; no production code change)
- chore: (updating grunt tasks etc; no production code change)
-->

## Release checklist

- [ ] Bump version (both Rust & R packages, accordingly)
- [ ] Update NEWS.md

### If dev release
- [ ] Precompiled Linux binaries
- [ ] Precompiled [Windows binaries](https://win-builder.r-project.org/upload.aspx) `devtools::check_win_devel()` 
- [ ] Precompiled [macOS binaries](https://mac.r-project.org/macbuilder/submit.html) `devtools::check_mac_release()`
- [ ] Update tag:
  - `git tag -m "update tag to new commit" -f -a TAG COMMIT_SHA`
  - `git push -f origin refs/tags/TAG`
