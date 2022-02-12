# Start via `make test-debug` or `make test-release`
async def test_basic(service_template_client):
    response = await service_template_client.post('/hello', json={})
    assert response.status == 200
