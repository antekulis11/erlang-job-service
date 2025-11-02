-module(job_sort).
-export([sort_tasks/1]).

sort_tasks(Tasks) ->
    TaskMap = maps:from_list([{maps:get(<<"name">>, T), T} || T <- Tasks]),
    DepMap = #{maps:get(<<"name">>, T) => maps:get(<<"requires">>, T, []) || T <- Tasks},
    RevMap = make_reverse_map(Tasks),
    case task_sort(DepMap, RevMap) of
        {ok, Names} -> {ok, [maps:get(N, TaskMap) || N <- Names]};
        Error -> Error
    end.

make_reverse_map(Tasks) ->
    lists:foldl(
      fun(Task, Acc) ->
          Name = maps:get(<<"name">>, Task),
          Requires = maps:get(<<"requires">>, Task, []),
          lists:foldl(fun(R, A) ->
              maps:update_with(R, fun(L) -> [Name | L] end, [Name], A)
          end, Acc, Requires)
      end, #{}, Tasks).

task_sort(DepMap, RevMap) ->
    Deps = maps:from_list([{N, length(Reqs)} || {N, Reqs} <- maps:to_list(DepMap)]),
    AvailableTasks = [N || {N, 0} <- maps:to_list(Deps)],
    process_tasks(RevMap, Deps, AvailableTasks, [], maps:size(DepMap)).

process_tasks(_RevMap, _Deps, [], Done, Total) when length(Done) < Total ->
    {error, <<"circular_dependency_detected">>};
process_tasks(_RevMap, _Deps, [], Done, _Total) ->
    {ok, Done};
process_tasks(RevMap, Deps, [Task | Rest], Done, Total) ->
    Dependents = maps:get(Task, RevMap, []),
    {NewDeps, NewAvailable} = lists:foldl(
        fun(Dep, {D, Avail}) ->
            case maps:get(Dep, D, 0) of
                1 -> {maps:put(Dep, 0, D), Avail ++ [Dep]};
                V when V > 1 -> {maps:put(Dep, V - 1, D), Avail};
                _ -> {D, Avail}
            end
        end, {Deps, Rest}, Dependents),
    process_tasks(RevMap, NewDeps, NewAvailable, Done ++ [Task], Total).
