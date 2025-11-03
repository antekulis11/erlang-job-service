job_service
=====

A simple **HTTP job processing service** in Erlang using **Cowboy**.
It sorts tasks with dependencies and can return them as JSON or as a Bash script.

## Project Overview

- `/jobs` → returns tasks in execution order (JSON).
- `/jobs/script` → returns a Bash script in execution order.

## Build
-----

    $ rebar3 compile

## Running the Server
-----
    $ rebar3 shell

    or manually:
    erl -pa _build/default/lib/cowboy/ebin \
        -pa _build/default/lib/cowlib/ebin \
        -pa _build/default/lib/ranch/ebin \
        -pa _build/default/lib/jiffy/ebin \
        -pa _build/default/lib/job_service/ebin

    1> start_server:start().


## Testing
-----
    $ curl.exe -X POST http://localhost:8080/jobs -H "Content-Type: application/json" --data-binary "@tasks.json"

    Output:

    {
        "tasks":
        [
            {"name":"task-1","command":"touch /tmp/file1"},
            {"name":"task-3","command":"echo Hello > /tmp/file1","requires":["task-1"]},
            {"name":"task-2","command":"cat /tmp/file1","requires":["task-3"]},
            {"name":"task-4","command":"rm /tmp/file1","requires":["task-2","task-3"]}
        ]
    }

    $ curl -X POST http://localhost:8080/jobs/script \
     -H "Content-Type: application/json" \
     --data-binary "@tasks.json"

     Output:

    #!/usr/bin/env bash
    touch /tmp/file1
    echo Hello > /tmp/file1
    cat /tmp/file1
    rm /tmp/file1
