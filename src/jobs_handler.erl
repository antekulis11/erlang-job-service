-module(jobs_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Json = jiffy:decode(Body, [return_maps]),
    Tasks = maps:get(<<"tasks">>, Json, []),
    case job_sort:sort_tasks(Tasks) of
        {ok, _SortedTasks} ->
            %%TODO implement
            Status = 200
    end,
    Reply = cowboy_req:reply(Status,
        #{},
        Body, Req1),
    {ok, Reply, State}.
