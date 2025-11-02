-module(start_server).
-export([start/0]).

start() ->
    _ = application:ensure_all_started(cowboy),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/jobs", jobs_handler, []},
            {"/jobs/script", jobs_script_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener, [{port, 8080}],
        #{env => #{dispatch => Dispatch}}),
    io:format("Server running on http://localhost:8080/~n").
