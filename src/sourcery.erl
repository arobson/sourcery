%%% @author Alex Robson <asrobson@gmail.com>
%%% @copyright 2013
%%% @doc
%%% 
%%% @end
%%% Licensed under the MIT license - http://www.opensource.org/licenses/mit-license
%%% Created November 10, 2013 by Alex Robson

-module(sourcery).

-export([start/0, stop/0]).


%% ==================================================================
%%  API
%% ==================================================================

start() ->
	application:load(sourcery),
	application:start(sourcery).

stop() ->
	application:stop(sourcery).