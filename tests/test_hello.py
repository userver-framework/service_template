import pytest

import handlers.hello_pb2 as hello_protos  # noqa: E402, E501

# Start the tests via `make test-debug` or `make test-release`


async def test_grpc_client(mock_grpc_server, grpc_service):
    @mock_grpc_server('SayHello')
    async def mock_say_hello(request, context):
        assert request.name
        return hello_protos.HelloResponse(
            text=f'{request.name}!!',
        )

    request = hello_protos.HelloRequest(name='mock_userver')
    response = await grpc_service.SayHello(request)
    assert response.text == 'Hello, userver!!!\n'
    assert mock_say_hello.times_called == 1


async def test_first_time_users(grpc_service):
    request = hello_protos.HelloRequest(name='userver')
    response = await grpc_service.SayHello(request)
    assert response.text == 'Hello, userver!\n'


async def test_db_updates(grpc_service):
    request = hello_protos.HelloRequest(name='World')
    response = await grpc_service.SayHello(request)
    assert response.text == 'Hello, World!\n'

    request = hello_protos.HelloRequest(name='World')
    response = await grpc_service.SayHello(request)
    assert response.text == 'Hi again, World!\n'

    request = hello_protos.HelloRequest(name='World')
    response = await grpc_service.SayHello(request)
    assert response.text == 'Hi again, World!\n'

