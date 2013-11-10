%%% @author Alex Robson <asrobson@gmail.com>
%%% @copyright 2013
%%% @doc
%%% 
%%% @end
%%% Licensed under the MIT license - http://www.opensource.org/licenses/mit-license
%%% Created November 10, 2013 by Alex Robson

-module(sourcery_sup).
-behaviour(supervisor).
-export([start_link/0, init/0]).

-define(SERVER, ?MODULE).

%%===================================================================
%%% API
%%===================================================================

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init() ->
	RestartStrategy = one_for_one,
    MaxRestarts = 3,
    MaxSecondsBetweenRestarts = 60,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    % _ = create_child_spec(_, worker, permanent, 1000, []),
    
    {ok, {SupFlags, []}}.

%%===================================================================
%%% Internal functions
%%===================================================================

create_child_spec(Child, Type, Restart, Shutdown, Args) ->
    {Child, { Child, start_link, Args }, Restart, Shutdown, Type, [Child]}.