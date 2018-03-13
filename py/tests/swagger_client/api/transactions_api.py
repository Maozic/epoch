# coding: utf-8

"""
    Aeternity Epoch

    This is the [Aeternity](https://www.aeternity.com/) Epoch API.  # noqa: E501

    OpenAPI spec version: 0.8.0
    Contact: apiteam@aeternity.com
    Generated by: https://github.com/swagger-api/swagger-codegen.git
"""


from __future__ import absolute_import

import re  # noqa: F401

# python 2 and python 3 compatibility library
import six

from swagger_client.api_client import ApiClient


class TransactionsApi(object):
    """NOTE: This class is auto generated by the swagger code generator program.

    Do not edit the class manually.
    Ref: https://github.com/swagger-api/swagger-codegen
    """

    def __init__(self, api_client=None):
        if api_client is None:
            api_client = ApiClient()
        self.api_client = api_client

    def get_account_transactions(self, account_pubkey, **kwargs):  # noqa: E501
        """get_account_transactions  # noqa: E501

        Get accounts's transactions included in blocks in the longest chain  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_account_transactions(account_pubkey, async=True)
        >>> result = thread.get()

        :param async bool
        :param str account_pubkey: Account pubkey to show transactions for (required)
        :param int limit: Maximum transactions count to show
        :param int offset: Offset to start transaction list from
        :param str tx_types: Transactions types to show. Comma separated
        :param str exclude_tx_types: Transactions types not to show. Comma separated. If a tx type appears in both tx_types and exclude_tx_types, it is excluded.
        :param str tx_encoding: Transactions encoding
        :return: TxObjects
                 If the method is called asynchronously,
                 returns the request thread.
        """
        kwargs['_return_http_data_only'] = True
        if kwargs.get('async'):
            return self.get_account_transactions_with_http_info(account_pubkey, **kwargs)  # noqa: E501
        else:
            (data) = self.get_account_transactions_with_http_info(account_pubkey, **kwargs)  # noqa: E501
            return data

    def get_account_transactions_with_http_info(self, account_pubkey, **kwargs):  # noqa: E501
        """get_account_transactions  # noqa: E501

        Get accounts's transactions included in blocks in the longest chain  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_account_transactions_with_http_info(account_pubkey, async=True)
        >>> result = thread.get()

        :param async bool
        :param str account_pubkey: Account pubkey to show transactions for (required)
        :param int limit: Maximum transactions count to show
        :param int offset: Offset to start transaction list from
        :param str tx_types: Transactions types to show. Comma separated
        :param str exclude_tx_types: Transactions types not to show. Comma separated. If a tx type appears in both tx_types and exclude_tx_types, it is excluded.
        :param str tx_encoding: Transactions encoding
        :return: TxObjects
                 If the method is called asynchronously,
                 returns the request thread.
        """

        all_params = ['account_pubkey', 'limit', 'offset', 'tx_types', 'exclude_tx_types', 'tx_encoding']  # noqa: E501
        all_params.append('async')
        all_params.append('_return_http_data_only')
        all_params.append('_preload_content')
        all_params.append('_request_timeout')

        params = locals()
        for key, val in six.iteritems(params['kwargs']):
            if key not in all_params:
                raise TypeError(
                    "Got an unexpected keyword argument '%s'"
                    " to method get_account_transactions" % key
                )
            params[key] = val
        del params['kwargs']
        # verify the required parameter 'account_pubkey' is set
        if ('account_pubkey' not in params or
                params['account_pubkey'] is None):
            raise ValueError("Missing the required parameter `account_pubkey` when calling `get_account_transactions`")  # noqa: E501

        if 'limit' in params and params['limit'] > 100:  # noqa: E501
            raise ValueError("Invalid value for parameter `limit` when calling `get_account_transactions`, must be a value less than or equal to `100`")  # noqa: E501
        if 'limit' in params and params['limit'] < 1:  # noqa: E501
            raise ValueError("Invalid value for parameter `limit` when calling `get_account_transactions`, must be a value greater than or equal to `1`")  # noqa: E501
        if 'offset' in params and params['offset'] < 0:  # noqa: E501
            raise ValueError("Invalid value for parameter `offset` when calling `get_account_transactions`, must be a value greater than or equal to `0`")  # noqa: E501
        collection_formats = {}

        path_params = {}
        if 'account_pubkey' in params:
            path_params['account_pubkey'] = params['account_pubkey']  # noqa: E501

        query_params = []
        if 'limit' in params:
            query_params.append(('limit', params['limit']))  # noqa: E501
        if 'offset' in params:
            query_params.append(('offset', params['offset']))  # noqa: E501
        if 'tx_types' in params:
            query_params.append(('tx_types', params['tx_types']))  # noqa: E501
        if 'exclude_tx_types' in params:
            query_params.append(('exclude_tx_types', params['exclude_tx_types']))  # noqa: E501
        if 'tx_encoding' in params:
            query_params.append(('tx_encoding', params['tx_encoding']))  # noqa: E501

        header_params = {}

        form_params = []
        local_var_files = {}

        body_params = None
        # HTTP header `Accept`
        header_params['Accept'] = self.api_client.select_header_accept(
            ['application/json'])  # noqa: E501

        # Authentication setting
        auth_settings = []  # noqa: E501

        return self.api_client.call_api(
            '/account/txs/{account_pubkey}', 'GET',
            path_params,
            query_params,
            header_params,
            body=body_params,
            post_params=form_params,
            files=local_var_files,
            response_type='TxObjects',  # noqa: E501
            auth_settings=auth_settings,
            async=params.get('async'),
            _return_http_data_only=params.get('_return_http_data_only'),
            _preload_content=params.get('_preload_content', True),
            _request_timeout=params.get('_request_timeout'),
            collection_formats=collection_formats)

    def get_tx(self, tx_hash, **kwargs):  # noqa: E501
        """get_tx  # noqa: E501

        Get a transaction by hash  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_tx(tx_hash, async=True)
        >>> result = thread.get()

        :param async bool
        :param str tx_hash: Hash of the transaction to get (required)
        :param str tx_encoding: Transaction encoding
        :return: SingleTxObject
                 If the method is called asynchronously,
                 returns the request thread.
        """
        kwargs['_return_http_data_only'] = True
        if kwargs.get('async'):
            return self.get_tx_with_http_info(tx_hash, **kwargs)  # noqa: E501
        else:
            (data) = self.get_tx_with_http_info(tx_hash, **kwargs)  # noqa: E501
            return data

    def get_tx_with_http_info(self, tx_hash, **kwargs):  # noqa: E501
        """get_tx  # noqa: E501

        Get a transaction by hash  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_tx_with_http_info(tx_hash, async=True)
        >>> result = thread.get()

        :param async bool
        :param str tx_hash: Hash of the transaction to get (required)
        :param str tx_encoding: Transaction encoding
        :return: SingleTxObject
                 If the method is called asynchronously,
                 returns the request thread.
        """

        all_params = ['tx_hash', 'tx_encoding']  # noqa: E501
        all_params.append('async')
        all_params.append('_return_http_data_only')
        all_params.append('_preload_content')
        all_params.append('_request_timeout')

        params = locals()
        for key, val in six.iteritems(params['kwargs']):
            if key not in all_params:
                raise TypeError(
                    "Got an unexpected keyword argument '%s'"
                    " to method get_tx" % key
                )
            params[key] = val
        del params['kwargs']
        # verify the required parameter 'tx_hash' is set
        if ('tx_hash' not in params or
                params['tx_hash'] is None):
            raise ValueError("Missing the required parameter `tx_hash` when calling `get_tx`")  # noqa: E501

        collection_formats = {}

        path_params = {}
        if 'tx_hash' in params:
            path_params['tx_hash'] = params['tx_hash']  # noqa: E501

        query_params = []
        if 'tx_encoding' in params:
            query_params.append(('tx_encoding', params['tx_encoding']))  # noqa: E501

        header_params = {}

        form_params = []
        local_var_files = {}

        body_params = None
        # HTTP header `Accept`
        header_params['Accept'] = self.api_client.select_header_accept(
            ['application/json'])  # noqa: E501

        # Authentication setting
        auth_settings = []  # noqa: E501

        return self.api_client.call_api(
            '/tx/{tx_hash}', 'GET',
            path_params,
            query_params,
            header_params,
            body=body_params,
            post_params=form_params,
            files=local_var_files,
            response_type='SingleTxObject',  # noqa: E501
            auth_settings=auth_settings,
            async=params.get('async'),
            _return_http_data_only=params.get('_return_http_data_only'),
            _preload_content=params.get('_preload_content', True),
            _request_timeout=params.get('_request_timeout'),
            collection_formats=collection_formats)

    def get_txs(self, **kwargs):  # noqa: E501
        """get_txs  # noqa: E501

        Get transactions in the mempool  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_txs(async=True)
        >>> result = thread.get()

        :param async bool
        :return: Transactions
                 If the method is called asynchronously,
                 returns the request thread.
        """
        kwargs['_return_http_data_only'] = True
        if kwargs.get('async'):
            return self.get_txs_with_http_info(**kwargs)  # noqa: E501
        else:
            (data) = self.get_txs_with_http_info(**kwargs)  # noqa: E501
            return data

    def get_txs_with_http_info(self, **kwargs):  # noqa: E501
        """get_txs  # noqa: E501

        Get transactions in the mempool  # noqa: E501
        This method makes a synchronous HTTP request by default. To make an
        asynchronous HTTP request, please pass async=True
        >>> thread = api.get_txs_with_http_info(async=True)
        >>> result = thread.get()

        :param async bool
        :return: Transactions
                 If the method is called asynchronously,
                 returns the request thread.
        """

        all_params = []  # noqa: E501
        all_params.append('async')
        all_params.append('_return_http_data_only')
        all_params.append('_preload_content')
        all_params.append('_request_timeout')

        params = locals()
        for key, val in six.iteritems(params['kwargs']):
            if key not in all_params:
                raise TypeError(
                    "Got an unexpected keyword argument '%s'"
                    " to method get_txs" % key
                )
            params[key] = val
        del params['kwargs']

        collection_formats = {}

        path_params = {}

        query_params = []

        header_params = {}

        form_params = []
        local_var_files = {}

        body_params = None
        # HTTP header `Accept`
        header_params['Accept'] = self.api_client.select_header_accept(
            ['application/json'])  # noqa: E501

        # Authentication setting
        auth_settings = []  # noqa: E501

        return self.api_client.call_api(
            '/transactions', 'GET',
            path_params,
            query_params,
            header_params,
            body=body_params,
            post_params=form_params,
            files=local_var_files,
            response_type='Transactions',  # noqa: E501
            auth_settings=auth_settings,
            async=params.get('async'),
            _return_http_data_only=params.get('_return_http_data_only'),
            _preload_content=params.get('_preload_content', True),
            _request_timeout=params.get('_request_timeout'),
            collection_formats=collection_formats)