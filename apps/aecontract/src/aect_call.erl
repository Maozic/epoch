%%%-------------------------------------------------------------------
%%% @copyright (C) 2017, Aeternity Anstalt
%%% @doc
%%% ADT for contract call objects.
%%% @end
%%%-------------------------------------------------------------------

-module(aect_call).

%% API
-export([ deserialize/1
        , id/1
        , id/3
        , new/5
        , contract_address/1
        , caller_address/1
        , caller_nonce/1
        , height/1
        , return_type/1
        , return_value/1
        , gas_price/1
        , gas_used/1
        , serialize/1
        , serialize_for_client/1
        , set_contract_address/2
        , set_caller_address/2
        , set_caller_nonce/2
        , set_height/2
        , set_return_type/2
        , set_return_value/2
        , set_gas_used/2
        , set_log/2
        , set_log_bloom/2
        ]).

-define(CONTRACT_INTERACTION_TYPE, contract_call).
-define(CONTRACT_INTERACTION_VSN, 2).
-define(CONTRACT_INTERACTION_VSN_PRE_LOG, 1).

%%%===================================================================
%%% Types
%%%===================================================================

-type log_entry() ::  list(). %% [binary()       160 bit account address
                              %%  [binary()]     topics
                              %%  binary()       data

-record(call, { caller_address   :: aec_keys:pubkey()
              , caller_nonce     :: integer()
              , height           :: aec_blocks:height()
              , contract_address :: aec_keys:pubkey()
              , gas_price        :: amount()
              , gas_used         :: amount()
              , return_value     :: binary()
	      , return_type      :: ok | error | revert
              , log              :: [log_entry()]
              , log_bloom        :: integer()
              }).

-opaque call() :: #call{}.
-type id() :: binary().
-type serialized() :: binary().
-type amount() :: aect_contracts:amount().

-export_type([ id/0
             , call/0
             , serialized/0
             ]).

-define(PUB_SIZE, 32).
-define(NONCE_SIZE, 256).

%%%===================================================================
%%% API
%%%===================================================================

-spec new(Caller::aec_keys:pubkey(), Nonce::non_neg_integer(), Address::aec_keys:pubkey(),
	  aec_blocks:height(), amount()) -> call().
new(Caller, Nonce, Address, BlockHeight, GasPrice) ->
    C = #call{ caller_address   = Caller
             , caller_nonce     = Nonce
             , height           = BlockHeight
             , contract_address = Address
             , gas_price        = GasPrice
             , gas_used         = 0     %% These are filled later
             , return_value     = <<>>  %% in aect_call_tx:process()
             , return_type      = ok
             , log              = []
             , log_bloom        = 0
             },
    assert_fields(C).

-spec id(call()) -> id().
id(I) ->
    id(I#call.caller_address,
       I#call.caller_nonce,
       I#call.contract_address).

-spec id(aec_keys:pubkey(), non_neg_integer(), aec_keys:pubkey()) -> id().
id(Caller, Nonce, Contract) ->
    Bin = <<Caller:?PUB_SIZE/binary,
            Nonce:?NONCE_SIZE,
            Contract:?PUB_SIZE/binary>>,
    aec_hash:hash(pubkey, Bin).

-spec serialize(call()) -> binary().
serialize(#call{} = I) ->
    LogBloom = log_bloom(I),
    aec_object_serialization:serialize(
      ?CONTRACT_INTERACTION_TYPE,
      ?CONTRACT_INTERACTION_VSN,
      serialization_template(?CONTRACT_INTERACTION_VSN),
      [ {caller_address, caller_address(I)}
      , {caller_nonce, caller_nonce(I)}
      , {height, height(I)}
      , {contract_address, contract_address(I)}
      , {gas_price, gas_price(I)}
      , {gas_used, gas_used(I)}
      , {return_value, return_value(I)}
      , {return_type, serialize_return_type(return_type(I))}
      , {log, serialize_log(log(I))}
      , {log_bloom, <<LogBloom:256>>}
     ]).

-spec deserialize(binary()) -> call().
deserialize(B) ->
    {?CONTRACT_INTERACTION_TYPE, Vsn, Fields} =
        aec_object_serialization:deserialize_type_and_vsn(B),
    case Vsn of
        ?CONTRACT_INTERACTION_VSN ->
            [ {caller_address, CallerAddress}
            , {caller_nonce, CallerNonce}
            , {height, Height}
            , {contract_address, ContractAddress}
            , {gas_price, GasPrice}
            , {gas_used, GasUsed}
            , {return_value, ReturnValue}
            , {return_type, ReturnType}
            , {log, Log}
            , {log_bloom, <<LogBloom:256/integer>>}
            ] = aec_serialization:decode_fields(
                  serialization_template(?CONTRACT_INTERACTION_VSN),
                  Fields);
        ?CONTRACT_INTERACTION_VSN_PRE_LOG ->
            [ {caller_address, CallerAddress}
            , {caller_nonce, CallerNonce}
            , {height, Height}
            , {contract_address, ContractAddress}
            , {gas_price, GasPrice}
            , {gas_used, GasUsed}
            , {return_value, ReturnValue}
            , {return_type, ReturnType}
            ] = aec_serialization:decode_fields(
                  serialization_template(?CONTRACT_INTERACTION_VSN_PRE_LOG),
                  Fields),
            Log = [],
            LogBloom = 0
    end,
    #call{ caller_address   = CallerAddress
         , caller_nonce     = CallerNonce
         , height           = Height
         , contract_address = ContractAddress
         , gas_price        = GasPrice
         , gas_used         = GasUsed
         , return_value     = ReturnValue
         , return_type      = deserialize_return_type(ReturnType)
         , log              = deserialize_log(Log)
         , log_bloom        = LogBloom
         }.

serialization_template(?CONTRACT_INTERACTION_VSN) ->
    [ {caller_address, binary}
    , {caller_nonce, int}
    , {height, int}
    , {contract_address, binary}
    , {gas_price, int}
    , {gas_used, int}
    , {return_value, binary}
    , {return_type, int}
    , {log, [{binary, [binary], binary}]}
    , {log_bloom, binary}
    ];
serialization_template(?CONTRACT_INTERACTION_VSN_PRE_LOG) ->
    [ {caller_address, binary}
    , {caller_nonce, int}
    , {height, int}
    , {contract_address, binary}
    , {gas_price, int}
    , {gas_used, int}
    , {return_value, binary}
    , {return_type, int}
    ].

serialize_return_type(ok) -> 0;
serialize_return_type(error) -> 1;
serialize_return_type(revert) ->  2.

deserialize_return_type(0) -> ok;
deserialize_return_type(1) -> error;
deserialize_return_type(2) -> revert.

serialize_log(Log) -> [serialize_log_entry(E) || E <- Log].
serialize_log_entry([Address, Topics, Data]) ->
    {Address, Topics, Data}.

deserialize_log(Log) -> [deserialize_log_entry(E) || E <- Log].
deserialize_log_entry({Address, Topics, Data}) ->
    [Address, Topics, Data].


serialize_for_client(#call{} = I) ->
    LogBloom = log_bloom(I),
    #{ <<"caller_address">>   => aec_base58c:encode(account_pubkey, caller_address(I))
     , <<"caller_nonce">>     => caller_nonce(I)
     , <<"height">>           => height(I)
     , <<"contract_address">> => aec_base58c:encode(contract_pubkey, contract_address(I))
     , <<"gas_price">>        => gas_price(I)
     , <<"gas_used">>         => gas_used(I)
     , <<"return_value">>     => list_to_binary(aect_utils:hex_bytes(return_value(I)))
     , <<"return_type">>      => atom_to_binary(return_type(I), utf8)
     , <<"log">>              => [serialize_log_entry_for_client(E) || E <- log(I)]
     , <<"log_bloom">>        => <<LogBloom:256>>
     }.

serialize_log_entry_for_client([Address, Topics, Data]) ->
    #{ <<"address">> => Address
     , <<"topics">>  => Topics
     , <<"data">>    => Data
     }.

%%%===================================================================
%%% Getters

-spec caller_address(call()) -> aec_keys:pubkey().
caller_address(I) -> I#call.caller_address.

-spec caller_nonce(call()) -> integer().
caller_nonce(I) -> I#call.caller_nonce.

-spec height(call()) -> aec_blocks:height().
height(I) -> I#call.height.

-spec contract_address(call()) -> aec_keys:pubkey().
contract_address(I) -> I#call.contract_address.

-spec return_type(call()) -> ok | error | revert.
return_type(I) -> I#call.return_type.

-spec return_value(call()) -> binary().
return_value(I) -> I#call.return_value.

-spec gas_price(call()) -> amount().
gas_price(I) -> I#call.gas_price.

-spec gas_used(call()) -> amount().
gas_used(I) -> I#call.gas_used.

-spec log(call()) -> [log_entry()].
log(I) -> I#call.log.

-spec log_bloom(call()) -> integer().
log_bloom(I) -> I#call.log_bloom.

%%%===================================================================
%%% Setters

-spec set_caller_address(aec_keys:pubkey(), call()) -> call().
set_caller_address(X, I) ->
    I#call{caller_address = assert_field(caller_address, X)}.

-spec set_caller_nonce(integer(), call()) -> call().
set_caller_nonce(X, I) ->
    I#call{caller_nonce = assert_field(caller_nonce, X)}.

-spec set_height(integer(), call()) -> call().
set_height(X, I) ->
    I#call{height = assert_field(height, X)}.

-spec set_contract_address(aec_keys:pubkey(), call()) -> call().
set_contract_address(X, I) ->
    I#call{contract_address = assert_field(contract_address, X)}.

-spec set_return_value(binary(), call()) -> call().
set_return_value(X, I) ->
    I#call{return_value = assert_field(return_value, X)}.

-spec set_return_type(ok | error | revert, call()) -> call().
set_return_type(ok, I) -> I#call{return_type = ok };
set_return_type(error, I) -> I#call{return_type = error };
set_return_type(revert, I) -> I#call{return_type = revert }.

-spec set_gas_used(integer(), call()) -> call().
set_gas_used(X, I) ->
    I#call{gas_used = assert_field(gas_used, X)}.

-spec set_log(list(), call()) -> call().
set_log(Log, I) ->
    I#call{log = assert_field(log, Log)}.

-spec set_log_bloom(integer(), call()) -> call().
set_log_bloom(LogBloom, I) ->
    I#call{log_bloom = assert_field(log_bloom, LogBloom)}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

assert_fields(I) ->
    List = [ {caller_address,   I#call.caller_address}
           , {caller_nonce,     I#call.caller_nonce}
           , {height,           I#call.height}
           , {contract_address, I#call.contract_address}
           , {return_value,     I#call.return_value}
           , {gas_price,        I#call.gas_price}
           , {gas_used,         I#call.gas_used}
           , {log,              I#call.log}
           , {log_bloom,        I#call.log_bloom}
           ],
    List1 = [try assert_field(X, Y), [] catch _:X -> X end
             || {X, Y} <- List],
    case lists:flatten(List1) of
        [] -> I;
        Other -> error({missing, Other})
    end.

assert_field(caller_address,   <<_:?PUB_SIZE/binary>> = X) -> X;
assert_field(caller_nonce,     X) when is_integer(X), X >= 0 -> X;
assert_field(height,           X) when is_integer(X), X > 0 -> X;
assert_field(contract_address, <<_:?PUB_SIZE/binary>> = X) -> X;
assert_field(return_value,     X) when is_binary(X) -> X;
assert_field(gas_price,        X) when is_integer(X), X >= 0 -> X;
assert_field(gas_used,         X) when is_integer(X), X >= 0 -> X;
assert_field(log,              []) -> [];
assert_field(log,              [[_A,_T,_D]=E|Log])-> [E|assert_field(log, Log)];
assert_field(log_bloom,        X) when is_integer(X) -> X;
assert_field(Field,            X) -> error({illegal, Field, X}).
