# how to use uv

starts the project:
`uv init`

add the main packages used by this test:
`uv add openai langfuse python-dotenv jupyter ipykernel`

this creates a .venv folder with the dependencies and a pyproject.toml file with the project metadata and dependencies.

`uv remove openai` removes the openai package from the project.

### how to add environments

`uv add {packagename} --dev` adds the package to the dev dependencies. this way we can separate environments for development and production, and more.

we can also run projects with:
`uv run {command}`

that way we can run our main project file.

`uv sync` will install the dependencies from the toml file

to activate the env we can run `source .venv/bin/activate`.

