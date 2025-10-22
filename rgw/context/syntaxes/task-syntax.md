# Task List Syntax

## Overview
This document defines a structured YAML format for implementation task lists generated from technical plans. The format supports phase-based organization, progress tracking, dependency management, and implementation feedback collection.

## Schema

```yaml
name: string
status: string
description: string
commit_message: string
prerequisites:
  - string
steps:
  - name: string
    description: string
    acceptance:
      - string
validation:
  - string
changed_files: array
```

## Field Descriptions

- name: concise, action-oriented task name
- status: indicates task execution progress. valid values are "to do", "in progress", "under review", "done".
- description: detailed description of what needs to be implemented
- commit_message: concise summary of the changes made, strictly following commit message patterns in the repo
- prerequisites: list of requirements that are required to start working on this task.
- steps: list of steps necessary to do the task. must be executed sequentially.
  - name: concise, action-oriented step name
  - description: detailed description of what needs to be done
  - acceptance: list of specific, testable criteria that define step completion
- validation: list of specific, testable criteria that define task completion
- changed_files: an empty array to be filled by hooks