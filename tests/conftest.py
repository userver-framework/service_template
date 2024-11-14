import pathlib
import sys

import pytest
import grpc

import handlers.hello_pb2_grpc as hello_services  # noqa: E402, E501

pytest_plugins = [
    'pytest_userver.plugins.mongo',
    'pytest_userver.plugins.grpc',
]


@pytest.fixture
def grpc_service(grpc_channel, service_client):
    return hello_services.HelloServiceStub(grpc_channel)


@pytest.fixture(scope='session')
def mock_grpc_hello_session(grpc_mockserver, create_grpc_mock):
    mock = create_grpc_mock(hello_services.HelloServiceServicer)
    hello_services.add_HelloServiceServicer_to_server(
        mock.servicer, grpc_mockserver,
    )
    return mock


@pytest.fixture
def mock_grpc_server(mock_grpc_hello_session):
    with mock_grpc_hello_session.mock() as mock:
        yield mock
