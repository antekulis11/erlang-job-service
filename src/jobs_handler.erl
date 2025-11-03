-module(jobs_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Json = jiffy:decode(Body, [return_maps]),
    Tasks = maps:get(<<"tasks">>, Json, []),
    {Status, ResponseJson} =
        case job_sort:sort_tasks(Tasks) of
            {ok, SortedTasks} ->
                {200, jiffy:encode(#{<<"tasks">> => SortedTasks}, [pretty])};
            {error, Reason} ->
                {400, jiffy:encode(#{<<"error">> => Reason}, [pretty])}
        end,
    Reply = cowboy_req:reply(Status,
        #{"content-type" => "application/json"},
        ResponseJson, Req1),
    {ok, Reply, State}.
