-module(jobs_script_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req, State) ->
    {ok, Body, Req1} = cowboy_req:read_body(Req),
    Json = jiffy:decode(Body, [return_maps]),
    Tasks = maps:get(<<"tasks">>, Json, []),
    case job_sort:sort_tasks(Tasks) of
        {ok, SortedTasks} ->
            Commands = [maps:get(<<"command">>, T) || T <- SortedTasks],
            Joined = binary:join(Commands, <<"\n">>),
            BashScript = <<"#!/usr/bin/env bash\n", Joined/binary, "\n">>,
            Reply = cowboy_req:reply(200,
                #{<<"content-type">> => <<"text/plain">>},
                BashScript, Req1),
            {ok, Reply, State};
        {error, Reason} ->
            ErrorMsg = io_lib:format("# Error: ~p~n", [Reason]),
            Reply = cowboy_req:reply(400,
                #{<<"content-type">> => <<"text/plain">>},
                lists:flatten(ErrorMsg), Req1),
            {ok, Reply, State}
    end.
