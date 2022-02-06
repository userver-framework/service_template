import pytest

@pytest.mark.asyncio
async def test_basic(server_client):
    response = await server_client.post('/hello', json={})
    assert response.status == 200
    assert handle_send.times_called == 1
