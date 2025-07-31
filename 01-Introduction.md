# AI Tooling investigation

## Requirements

### Pull-request reviews

- Access the bitbucket server via MCP
- Read pull request changes
- Get context via the repository protocol (with repomix or similar compression, for sparing token usage)
- Read through all the repository codebase
- Analyze the pull-request via predefined commands (EXPECTATIONS.md)
- Give feedback through the MCP protocol for line-by-line analysis for all predefined points in the EXPECTATIONS.md file
- Feedback can be validated using static analysis and unit testing where available.
- Give general feedback for the overall pull-request

MCP protocol has ability to retrieve the current pull-request contents via `getPullRequest` MCP call. It should read
through the diff and get further context from the repomix compressed format, the branch and apply compression to it 
via `repomix --compression ssh://bitbucket.doclerholding.com/reponame#branchname`. No further modification is required.
It should then read the EXPECTATIONS.md file for further instructions on code-review points.

Pull-request review policies should be added to the CLAUDE.md specification file that the LLM would read before
interacting with the codebase.

#### Pull-request policies

All reading requirements should be defined in the CLAUDE.md file. When providing feedback or code samples, static
analysis and testing should be applied to all suggestions. The way these static analysis is run has to be predefined in
the CLAUDE.md file, so that the agent has access to the same tooling as the developer. The agent's running environment
has to support the original development environment's features (e.g. should have node installed if the project requires
it). The agent should have access.

#### EXPECTATIONS.md specification

- Try to make sure to not over emphasize any negative points because it could create negative bias.
- Make sure to emphasize important points with YOU MUST or YOU SHOULD in uppercase letters when important modifications
  are needed.
- When providing multiple instruction sets try to group them by ## headings and/or bullet points.
- Try to make the EXPECTATIONS.md file as short as possible while also separating any individual points into groups,
  that the LLM can walk through.
