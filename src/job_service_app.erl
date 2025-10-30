%%%-------------------------------------------------------------------
%% @doc job_service public API
%% @end
%%%-------------------------------------------------------------------

-module(job_service_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    job_service_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
