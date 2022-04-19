# Start via `make test-debug` or `make test-release`
async def test_basic(service_client):
    response = await service_client.post('/hello', json={})
    assert response.status == 200
