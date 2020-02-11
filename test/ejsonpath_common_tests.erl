-module(ejsonpath_common_tests).

-compile([export_all, nowarn_export_all]).

-include_lib("eunit/include/eunit.hrl").

buildpath_test() ->
    ?assertEqual("$['xyz']", ejsonpath_common:buildpath("xyz", "$")),
    ?assertEqual("$['xyz']", ejsonpath_common:buildpath(<<"xyz">>, "$")),
    ?assertEqual("$['xyz']", ejsonpath_common:buildpath(xyz, "$")),
    ?assertEqual("$[0]", ejsonpath_common:buildpath(0, "$")),
    ok.

type_test() ->
    % array
    ?assertEqual(array, ejsonpath_common:type([])),
    ?assertEqual(array, ejsonpath_common:type([1,2,3])),
    ?assertEqual(array, ejsonpath_common:type("xyz")),
    
    % hash
    ?assertEqual(hash, ejsonpath_common:type(#{})),
    ?assertEqual(hash, ejsonpath_common:type(#{ <<"x">> => 1})),
    
    % string
    ?assertEqual(string, ejsonpath_common:type(<<>>)),
    ?assertEqual(string, ejsonpath_common:type(xyz)),
    ?assertEqual(string, ejsonpath_common:type(<<"xyz">>)),

    % number
    ?assertEqual(number, ejsonpath_common:type(0)),
    ?assertEqual(number, ejsonpath_common:type(0.0)),
    
    % boolean
    ?assertEqual(boolean, ejsonpath_common:type(true)),
    ?assertEqual(boolean, ejsonpath_common:type(false)),
    
    % null
    ?assertEqual(null, ejsonpath_common:type(null)),
    
    ok.

index_test() ->
    ?assertEqual({error, badarg}, ejsonpath_common:index(0, -1)),
    ?assertEqual({error, badarg}, ejsonpath_common:index(0, 0)),
    ?assertEqual({error, badarg}, ejsonpath_common:index(1, 0)),
    ?assertEqual({error, badarg}, ejsonpath_common:index(1, 1)),
    ?assertEqual({error, badarg}, ejsonpath_common:index(<<"10">>, 1)),

    ?assertEqual({ok, 1}, ejsonpath_common:index(0, 1)),
    ?assertEqual({ok, 5}, ejsonpath_common:index(4, 10)),

    ok.

insert_list_test() ->
    ?assertError(badarg, ejsonpath_common:insert_list(-1, x, [a])),
    ?assertError(badarg, ejsonpath_common:insert_list(0, x, [a])),
    ?assertError(badarg, ejsonpath_common:insert_list(2, x, [a])),

    ?assertEqual([x], ejsonpath_common:insert_list(1, x, [a])),

    ?assertEqual([x,y,z], ejsonpath_common:insert_list(1, x, [a,y,z])),
    ?assertEqual([x,y,z], ejsonpath_common:insert_list(2, y, [x,a,z])),
    ?assertEqual([x,y,z], ejsonpath_common:insert_list(3, z, [x,y,a])),
    
    ok.

slice_seq_test() ->
    ?assertEqual({error, badarg}, ejsonpath_common:slice_seq(0, 0, 0, 0)),
    ?assertEqual({error, badarg}, ejsonpath_common:slice_seq(0, 0, 0, -1)),
    ?assertEqual({error, badarg}, ejsonpath_common:slice_seq(0, 0, -1, 0)),
    
    ?assertEqual([], ejsonpath_common:slice_seq(0, 0, 1, 3)),
    ?assertEqual([0], ejsonpath_common:slice_seq(0, 1, 1, 3)),
    ?assertEqual([0, 1, 2], ejsonpath_common:slice_seq(0, 3, 1, 3)),
    ?assertEqual([0, 1, 2], ejsonpath_common:slice_seq(0, '$end', 1, 3)),
    ?assertEqual([0, 1], ejsonpath_common:slice_seq(0, -1, 1, 3)),
    ?assertEqual([1], ejsonpath_common:slice_seq(1, -1, 1, 3)),

    ?assertEqual([], ejsonpath_common:slice_seq(10, 10, 1, 4)),
    ?assertEqual([], ejsonpath_common:slice_seq(10, -1, 1, 3)),
    ?assertEqual([0,1,2], ejsonpath_common:slice_seq(0, 10, 1, 3)),

    ok.

keyaccess_fun_test() ->
    ?assertError(badfun, ejsonpath_common:keyaccess([keyaccess])),
    ?assertError(badfun, ejsonpath_common:keyaccess([{keyaccess, 0}])),
    ?assertError(badfun, ejsonpath_common:keyaccess([{keyaccess, fun(_, _) -> ok end}])),

    KeyAccess = fun (X) -> erlang:binary_to_existing_atom(X, utf8) end,
    ?assertEqual(KeyAccess, ejsonpath_common:keyaccess([{keyaccess, KeyAccess}])),
    ?assertEqual(fun ejsonpath_common:identity/1, ejsonpath_common:keyaccess([])),

    ok.