%%%-------------------------------------------------------------------
%% @doc job_service public API
%% @end
%%%-------------------------------------------------------------------

-module(job_service_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    io:format("Starting job service...~n"),
    _= application:ensure_all_started(cowboy),
    start_server:start(),
    {ok, self()}.

stop(_State) ->
    io:format("Stoping job service...~n"),
    ok.

%% internal functions
